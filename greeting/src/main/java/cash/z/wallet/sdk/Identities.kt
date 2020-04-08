package cash.z.wallet.sdk

import android.content.Context
import android.content.SharedPreferences
import cash.z.wallet.sdk.exception.BirthdayException
import cash.z.wallet.sdk.exception.InitializerException
//import cash.z.wallet.sdk.block.CompactBlockProcessor
import cash.z.wallet.sdk.ext.*
import cash.z.wallet.sdk.Initializer
import cash.z.wallet.sdk.Initializer.WalletBirthday
import cash.z.wallet.sdk.Synchronizer.AddressType.Shielded
import cash.z.wallet.sdk.Synchronizer.AddressType.Transparent
import cash.z.wallet.sdk.Synchronizer.Status.*
import cash.z.wallet.sdk.block.CompactBlockDbStore
import cash.z.wallet.sdk.block.CompactBlockDownloader
import cash.z.wallet.sdk.block.CompactBlockProcessor
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
import kotlinx.coroutines.*
import kotlinx.coroutines.Deferred
import cash.z.wallet.sdk.rpc.Service

import kotlinx.coroutines.channels.ConflatedBroadcastChannel
import kotlinx.coroutines.flow.*
import kotlin.coroutines.CoroutineContext
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers.IO
import kotlinx.coroutines.Dispatchers.Default
import kotlinx.coroutines.Dispatchers.Main

class Identities(){

  private var name: String = "";
  private var contentMap: Map<String, String>? = null;
  private var primaryAddresses: List<String>? = null;
  private var minimumSignatures = -1;
  private var privateAddress = "";
  private var revocationAuthority = "";
  private var recoveryAuthority = "";
  private var flags = -1;
  private var version = -1;
  private var parent = "";
  private var status = "";
  private var canSignFor: Boolean? = null;
  private var canSpendFor: Boolean? = null;
  private var blockHeigt: Long = -1;
  private var txId = "";
  private var vOut = -1;
  private var salt = "";
  private var nameId = "";
  private var referralIdentity = "";

  public fun getName(): String{
    return name;
  }

  public fun getContentMap(): Map<String, String>?{
    return contentMap;
  }

  public fun getAddresses(): List<String>?{
    return primaryAddresses;
  }

  public fun getMinimumSignatures(): Int{
    return minimumSignatures;
  }

  public fun getPrivateAddress(): String{
    return privateAddress;
  }

  public fun getRecoveryAuthority(): String{
    return recoveryAuthority;
  }

  public fun getFlags(): Int{
    return flags;
  }

  public fun getVersion(): Int{
    return version;
  }

  public fun getParent(): String{
    return parent;
  }

  public fun getCanSignFor(): Boolean?{
    return canSignFor;
  }

  public fun getCanSpendFor(): Boolean?{
    return canSpendFor;
  }

  public fun getBlockHeight(): Long{
    return blockHeigt;
  }

  public fun getVout(): Int{
    return vOut;
  }

  public fun getTxid(): String{
    return txId;
  }

  public fun getSalt(): String{
    return salt;
  }

  public fun getNameId(): String{
    return nameId;
  }

  public fun getReferalId(): String{
    return referralIdentity;
  }

  public fun getRevocationAuthority(): String{
    return revocationAuthority;
  }

  public fun getStatus(): String{
    return status;
  }

  public fun updateIdentityInfo( identityInfo: Service.IdentityInfo) {
      status = identityInfo.getStatus();
      canSignFor = identityInfo.getCansignfor();
      canSpendFor = identityInfo.getCanspendfor();
      blockHeigt = identityInfo.getBlockheight();
      txId = identityInfo.getTxid();
      vOut = identityInfo.getVout();
  }



  public fun updateNameReservation(
    nameReservation: Service.NameReservation
    ){
      name = nameReservation.getName();
      salt = nameReservation.getSalt();
      nameId = nameReservation.getNameid();
      referralIdentity = nameReservation.getReferral();
      parent = nameReservation.getParent();
    }

    public fun setIdentity(identity: Service.Identity){
      name = identity.getName();
      contentMap = identity.getContentmap();
      revocationAuthority = identity.getRevocationauthority();
      primaryAddresses = identity.getPrimaryaddressesList();
      minimumSignatures = identity.getMinimumsignatures();
      privateAddress = identity.getPrivateaddress();
      recoveryAuthority = identity.getRecoveryauthority();
      flags = identity.getFlags();
      version = identity.getVersion();
      parent = identity.getParent();
    }

}
