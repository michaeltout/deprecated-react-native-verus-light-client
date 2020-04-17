package cash.z.wallet.sdk

import android.content.Context
import android.content.SharedPreferences
import cash.z.wallet.sdk.exception.BirthdayException
import cash.z.wallet.sdk.exception.InitializerException
import cash.z.wallet.sdk.block.CompactBlockProcessor
import cash.z.wallet.sdk.ext.*
import cash.z.wallet.sdk.Initializer
import cash.z.wallet.sdk.Initializer.*
import cash.z.wallet.sdk.Coins
import cash.z.wallet.sdk.rpc.Service
import cash.z.wallet.sdk.Initializer.WalletBirthday
import cash.z.wallet.sdk.Synchronizer.AddressType.Shielded
import cash.z.wallet.sdk.Synchronizer.AddressType.Transparent
import cash.z.wallet.sdk.Synchronizer.Status.*
import cash.z.wallet.sdk.block.CompactBlockDbStore
import cash.z.wallet.sdk.block.CompactBlockDownloader
import cash.z.wallet.sdk.block.CompactBlockProcessor.*
import cash.z.wallet.sdk.block.CompactBlockProcessor.State.*
import cash.z.wallet.sdk.block.CompactBlockProcessor.WalletBalance
import cash.z.wallet.sdk.block.CompactBlockStore
import cash.z.wallet.sdk.entity.*
import cash.z.wallet.sdk.exception.SynchronizerException
import cash.z.wallet.sdk.ext.ZcashSdk
import cash.z.wallet.sdk.ext.twig
import cash.z.wallet.sdk.ext.twigTask
import cash.z.wallet.sdk.jni.RustBackend
import cash.z.wallet.sdk.service.LightWalletGrpcService
import cash.z.wallet.sdk.service.LightWalletService
import cash.z.wallet.sdk.transaction.*
import cash.z.wallet.sdk.DemoConfig
import cash.z.wallet.sdk.Identities
import kotlinx.coroutines.*
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.channels.ConflatedBroadcastChannel
import kotlinx.coroutines.flow.*
import kotlin.coroutines.CoroutineContext
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers.IO
import kotlinx.coroutines.Dispatchers.Default
import kotlinx.coroutines.Dispatchers.Main

import java.util.*
import java.io.File


class KtJavaComLayer (){
	/* todo, syncronizer and client are ready for multicoin. Now just change in all functions.
	Then clean the code up */


	/*you need a comunication layer for static-java to be able to call Kotlin*/
	companion object { //everything needs a companion object so it can be called form a static enviroment
	private  val coins = ArrayList<Coins>();
	private lateinit var BlockHeigt: String; //holds the blockheigt as string
	//tx flow is not nesccairy here, however having it here is benefical form possible
	//future developement if you want anything to hook to this state change.
	private var txFlow: Flow<PendingTransaction>? = null;
	//this holds the lightwalletService? point.
	//it is also initialzed everytime it is used, because it seems lik you need  a
	//fresh instance everytime you use it. However it can still be usefull, if you
	//want anything hooking into state changes.
	private var lightwalletService: LightWalletService? = null;

		//initialzes the client, this will create a new one
		fun InitClient(mContext: Context, index: Int): String = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
			try{
			withContext(IO){
				coins[index].putInitClient(mContext);
				"true";
				}
			}catch(e: Exception){
				val error = e.toString();
				"error: $error";
			}
		}
	}

//adds a coin object, the object that enables multicoin functionality.
	fun addCoin(icoinId: String, iProtocol: String, iAccountHash: String, mContext: Context, seedInByteArray: ByteArray,
		host: String, port: Int, seed: String, birthdayString: String, birthdayInt: Int, numberOfAccounts: Int): Int{
		var indexNumber: Int = 0;
		if(coins != null){
			indexNumber = coins.size;
		}
		val newCoins = Coins(icoinId, iProtocol, iAccountHash, indexNumber, mContext, seedInByteArray, port, host, seed, "", birthdayString, birthdayInt, numberOfAccounts);
		coins.add(newCoins);
		return coins.size -1;
	}

	//gets the path of something with name path
	fun getPath(context: Context, path: String): String{
		return Initializer.dataDbPath(context, path);
	}

	//initializes syncronizer for the first time
	fun Initer(mContext: Context, path: String, index: Int): String{
		if(index == -1){
			return	"error: not initialized coin usage";
		}else{
		try{
		val checkPath = Initializer.dataDbPath(mContext, path);
		val file = File(checkPath);

		coins[index].initializer = Initializer(mContext, path); //path
		if(file.exists() == true){
			coins[index].putInitOpen();
		}else{
			coins[index].putInitNew();
		}
	}catch(e: Exception){
		val error = e.toString();
		return "error: $error";
	}
		return "true";
	}
	}


	//starts the sycronizer
	fun syncronizerstart(mContext: Context, index: Int): String {
		if(index == -1){
				return "error: not initialized coin usage";
		}else{
		if(coins[index].initializer != null){
			coins[index].synchronizer = Synchronizer(mContext, coins[index].initializer!!);
			try{
				GlobalScope.launch { //has to happen here, becuase java does not have coroutines
						coins[index].synchronizer?.start(this);
				}
				return "true";
			}catch(e: Exception){
					val error = e.toString();
					return "error: $error";
			}
		}else{
			return "error: initialize the wallet first";
		}
	}
	}


	/*stop functions*/
	fun syncronizerStop(index: Int): String = runBlocking{
		try{
				coins[index].synchronizer?.stop();
				coins[index].synchronizer = null;
			 "true";
		}	 catch (e: Exception) {
				val error = e.toString();
				"error: $error";
		}
	}

	//deletes the initializer
	fun interDelete(index: Int): String = runBlocking{
		if(index == -1){
				"error: not initialized coin usage";
		}else{
		try{
			coins[index].initializer?.clear();
			coins[index].initializer = null;
			"true";
		}catch (e: Exception) {
				val error = e.toString();
			"error: $error";
		}
	}
	}

	//functions for the module
		fun returnClient(index: Int): String?{
			if(index == -1){
				return	"error: not initialized coin usage";
			}else{
			if(lightwalletService != null){
				return lightwalletService?.toString();
			 }else{
				 return "not initialzed yet";
			 }
		 }
		}

		//the dirty functions are composed of multiple kotlin functions to achieve
		//the perpose that is outlined in the heading comment.
		//call only the dirty fucntions from java. all other functions at own risk

		//returns BlockHeigt
		fun getBlockHeightDirty(mContext: Context, index: Int): String = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
					initLightWalletService(mContext, index);
					getBlockHeight(index);
					BlockHeigt;
				}
		}

		//returns blockrage
		fun getBlockRangeDirty(mContext: Context, rangeStart: Int, rangeStop: Int, index: Int): String? = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
				val range = IntRange(rangeStart, rangeStop);
				initLightWalletService(mContext, index);
				getBlockRage(range, index);
			}
		}

		//returns block infomarion
		fun getBlockDirty(mContext: Context, blockNumber: Int, index: Int): String? = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
			val range = IntRange(blockNumber, blockNumber);
			initLightWalletService(mContext, index);
			getBlockRage(range, index);
		}
		}

		//return address
		fun getAddressDirty(index: Int): Array<out String?> = runBlocking{
			if(index == -1){
				val errorArray = ArrayList<String>();
				errorArray.add("error: not initialized coin usage");
				var array = arrayOfNulls<String>(errorArray.size);
				errorArray.toArray(array);

			}else{
				//val stonks =
			 coins[index].getAddress();
				//stonks[0];
				/*var answere = "";
				for(x in 0 until stonks.size){
					if(x == (stonks.size - 1)){
						answere = answere + stonks[x];
					}else{
						answere = answere + stonks[x] +", ";
					}
				}
			answere;*/
		}
		}

		//return privatekey
		fun getPrivateKeyDirty(seed: ByteArray, index: Int): String = runBlocking{
			if(index == -1){
				"error: not initialized coin usage"
			}else{
			 coins[index].getPrivKey();
		 }
		}

		//return list of transactions
		fun getListOfTransactionDirty(mContext: Context, info: String, index: Int): Array<String?> = runBlocking{
			if(index == -1){
				val errorArray = ArrayList<String>();
				errorArray.add("error: not initialized coin usage");
				var array = arrayOfNulls<String>(errorArray.size);
				errorArray.toArray(array);
				array;
			}else{
			//[ "pending" OR "cleared" OR "received" OR "sent" OR "all"]
			var stonks: String = "";
			var arraylist = ArrayList<String>();
			if(coins[index].synchronizer != null){
			if(info.equals("pending")){
				coins[index].synchronizer?.pendingTransactions!!.collect(
					{
						x ->
						var meme = x.toList();
						for(p in 0 until meme.size){
//here we can add all values together in
//"address": "2ei2joffd2", "amount": 15.160704, "category": "sent", "status": "confirmed", time: "341431", "txid": "3242edc2c2", "height": "312312"
							val info: String = "address, " + meme[p]!!.toAddress.toString() + ", amount, " + meme[p]!!.value.toString() +
							", catagory, pending, status, unconfirmed, time, , txid, " +  meme[p]!!.id.toString() + ", height, -1"
							arraylist.add(info)
						}
					}
					);
				}
			if(info.equals("cleared")){
						coins[index].synchronizer?.clearedTransactions!!.collect({
						x ->
						var meme = x.toList()
						for(p in 0 until meme.size){
							val info: String = "address, " + meme[p]!!.toAddress.toString() + ", amount, " + meme[p]!!.value.toString() +
							", catagory, cleared, status, confirmed, time," + meme[p]!!.blockTimeInSeconds.toString() +" , txid, " +  meme[p]!!.id.toString() + ", height," + meme[p]!!.minedHeight.toString()
							//here we can add all values together in
							//one big string
							arraylist.add(info)
						}
					}
					);
			}
			if(info.equals("received")){
				coins[index].synchronizer?.receivedTransactions!!.collect(
					{
						x ->
						var meme = x.toList();
						for(p in 0 until meme.size){
							val info: String = "address, " + meme[p]!!.toAddress.toString() + ", amount, " + meme[p]!!.value.toString() +
							", catagory, recieved, status, confirmed, time," + meme[p]!!.blockTimeInSeconds.toString() +" , txid, " +  meme[p]!!.id.toString() + ", height," + meme[p]!!.minedHeight.toString()
							//here we can add all values together in
							//one big string
							arraylist.add(info)
						}
					}
					);
			}
			if(info.equals("sent")){
				coins[index].synchronizer?.sentTransactions!!.collect({
					x ->
					var meme = x.toList();
					for(p in 0 until meme.size){
						val info: String = "address, " + meme[p]!!.toAddress.toString() + ", amount, " + meme[p]!!.value.toString() +
						", catagory, sent, status, confirmed, time," + meme[p]!!.blockTimeInSeconds.toString() +" , txid, " +  meme[p]!!.id.toString() + ", height," + meme[p]!!.minedHeight.toString()
						//here we can add all values together in
						//one big string
						arraylist.add(info)
					}
				}
				);
			}
			}else{
				"error: syncronizer has not been started";
			}
		var array = arrayOfNulls<String>(arraylist.size);
		arraylist.toArray(array);
		array;
	}
	}

		//get sync status
		fun getSyncStatusDirty(index: Int): String = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
				if(coins[index].synchronizer != null){
				var stonks: String = "";
				coins[index].synchronizer?.status?.collect(
					{
						x ->
						stonks = x.name;
					}
					);
					stonks;
				}else{
					"error: syncronizer has not been started";
				}
			}
		}

		//gets the syncronizer progress on downloading the blockchain
		fun getSyncProgressDirty(index: Int): String = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
			if( coins[index].synchronizer != null){
				coins[index].synchronizer?.progress.toString()!!;
			}else{
				"error: Not initialized"
			}
		}
		}

		fun getIdentityDirty(context: Context, index: Int, identity: String): Identities?{
			if(index == -1){
					return null;
			}else{
			coins[index].putInitClient(context);
			lateinit var rawIdentity: Service.IdentityInfo;
			try {
				 rawIdentity = coins[index].client?.getIdentities(identity)!!;
			}catch(ex:Exception) {

			}
			val identity = Identities();
			identity.setIdentity(rawIdentity?.getIdentity()!!);
			//identity.updateIdentityInfo(rawIdentity!!);
			return identity;
		}
		}

		fun getIdentityInfoDirty(context: Context, index: Int, identity: String): Identities?{
			if(index == -1){
					return null;
			}else{
				coins[index].putInitClient(context);
				lateinit var rawIdentityInfo: Service.IdentityInfo;
				try {
					 rawIdentityInfo = coins[index].client?.getIdentities(identity)!!;
				}catch(ex:Exception) {

				}
				val identity = Identities();
				identity.setIdentity(rawIdentityInfo?.getIdentity()!!);
				identity.updateIdentityInfo(rawIdentityInfo!!);
				return identity;
			}
		}

		fun verifyMessageDirty(context: Context, index: Int,signer: String, signature: String, message: String, checklast: Boolean): Boolean?{
			if(index == -1){
				return null;
			}else{
			coins[index].putInitClient(context);
			var response: Boolean? = null;
				try {
					response = coins[index].client?.verifyMessage(signer, signature, message, checklast);
				}catch(ex:Exception) {

				}
				return response;
			}
		}

		//gets the wallet balance of all the addresses
		fun getWalletBalanceDirty( includePending: Boolean, address: String, index: Int): String = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
			val numberOfAccounts = coins[index].getNumberOfAccounts();
			var totalBalance: Long = 0;
			var availableBalance: Long = 0;
			if(coins[index].synchronizer != null){
			if(address == ""){
				for(x in 0 until numberOfAccounts){
					if(includePending == false){
						totalBalance = totalBalance + coins[index].synchronizer?.blockProcessor?.getBalanceConfirmed(x)!!.totalZatoshi;
						availableBalance = availableBalance + coins[index].synchronizer?.blockProcessor?.getBalanceConfirmed(x)!!.availableZatoshi;
					}else{
						totalBalance = totalBalance + coins[index].synchronizer?.blockProcessor?.getBalanceInfo(x)!!.totalZatoshi;
							availableBalance = availableBalance  + coins[index].synchronizer?.blockProcessor?.getBalanceInfo(x)!!.availableZatoshi;
					}
				}
			}else{
				val index: Int = coins[index].getAccountIndex(address);
				if(includePending == false){
					totalBalance = totalBalance + coins[index].synchronizer?.blockProcessor?.getBalanceConfirmed(index)!!.totalZatoshi;
					availableBalance = availableBalance + coins[index].synchronizer?.blockProcessor?.getBalanceConfirmed(index)!!.availableZatoshi;
				}else{
					totalBalance = totalBalance + coins[index].synchronizer?.blockProcessor?.getBalanceInfo(index)!!.totalZatoshi;
						availableBalance = availableBalance  + coins[index].synchronizer?.blockProcessor?.getBalanceInfo(index)!!.availableZatoshi;
				}
			}
			val aB = availableBalance.toString();
			val tB = totalBalance.toString();
			"total: " + tB + ", confirmed: " + aB + "";
			}else{
				"error: syncronizer has not been started";
			}
		}
		}

		//sends a transactions
		fun putSendDirty(mContext: Context, toAddress: String, fromAddress: String, amount: Long, memo: String, index: Int): String = runBlocking{
			if(index == -1){
					"error: not initialized coin usage";
			}else{
				if(coins[index].synchronizer != null){
			val toAddress = coins[index].synchronizer?.getAddress()!!; //address delete later
			var text: String = "haha";
			val fromIndex = coins[index].getAccountIndex(fromAddress);
			try{
				txFlow = coins[index].synchronizer?.sendToAddress(coins[index].getPrivKey(), amount, toAddress, memo, fromIndex);
				text = "pending"
			} catch (e: Exception) {
    		text = "The flow has thrown an exception: $e";
			}
			text;
				}else{
					"error: syncronizer has not been started";
				}
			}
	}

		//helper methods
		private fun initLightWalletService(mContext: Context, index: Int){
			if(index == -1){
					"error: not initialized coin usage";
			}else{
			coins[index].putInitClient(mContext);
		}
		}

		//sets the BlockHeigt
		private fun getBlockHeight(index: Int){
			if(index == -1){
					"error: not initialized coin usage";
			}else{
				BlockHeigt = coins[index].client?.getLatestBlockHeight().toString() ?: "null error";
			}
		}

		//gets blockrange
		private fun getBlockRage(range: IntRange, index: Int): String?{
			if(index == -1){
				return "error: not initialized coin usage";
			}else{
				return coins[index].client?.getBlockRange(range).toString();
			}
		}

		//gets spendingKeys
		private fun getSpendingKeys(seed: ByteArray, index: Int): String?{
			if(index == -1){
				return "error: not initialized coin usage";
			}else{
			 return coins[index].getSpendingKeys();
		 }
		}

		//watchout this one is in string
		private fun getViewingKeys(index: Int): String?{
			if(index == -1){
				return "error: not initialized coin usage";
			}else{
			return coins[index].getViewingKeys();
		}
		}

		//gets the list of address
		private fun getAddress(index: Int): Array<String>{
			if(index == -1){
				val errorArray = ArrayList<String>();
				errorArray.add("error: not initialized coin usage");
				var array = arrayOfNulls<String?>(errorArray.size);
				return errorArray.toArray(array);
			}else{
			return coins[index].getAddress();
		}
		}

		//helper with blockheight, might delete
		private fun returnBlockHeigt(index: Int): String?{
			if(index == -1){
				return "error: not initialized coin usage";
			}else{
			if(::BlockHeigt.isInitialized){
			return BlockHeigt;
		}else{
			return "Late Init not done";
		}
	}
		}
		//companion object
	}
	//the class
}
