package cash.z.wallet.sdk.demoapp.demos.listtransactions

import android.view.LayoutInflater
import android.content.Context
import android.view.View
import androidx.lifecycle.lifecycleScope
import androidx.paging.PagedList
import androidx.recyclerview.widget.LinearLayoutManager
import cash.z.wallet.sdk.Initializer
import cash.z.wallet.sdk.Synchronizer
import cash.z.wallet.sdk.block.CompactBlockProcessor
import cash.z.wallet.sdk.demoapp.App
import cash.z.wallet.sdk.demoapp.BaseDemoFragment
import cash.z.wallet.sdk.demoapp.databinding.FragmentListTransactionsBinding
import cash.z.wallet.sdk.db.entity.ConfirmedTransaction
import cash.z.wallet.sdk.ext.collectWith
import cash.z.wallet.sdk.ext.twig
import cash.z.wallet.sdk.KtJavaComLayer
import cash.z.wallet.sdk.Coins
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * List all transactions related to the given seed, since the given birthday. This begins by
 * downloading any missing blocks and then validating and scanning their contents. Once scan is
 * complete, the transactions are available in the database and can be accessed by any SQL tool.
 * By default, the SDK uses a PagedTransactionRepository to provide transaction contents from the
 * database in a paged format that works natively with RecyclerViews.
 */
class ListTransactionsFragment : BaseDemoFragment<FragmentListTransactionsBinding>() {
    private val config = App.instance.defaultConfig
    private val initializer = Initializer(App.instance, alias="chris", host = config.host, port = config.port )
    private val birthday = config.loadBirthday()
    private var coinNumber = -1;
    private lateinit var synchronizer: Synchronizer
    private lateinit var adapter: TransactionAdapter<ConfirmedTransaction>
    private lateinit var address: String
    private var status: Synchronizer.Status? = null

    private val isSynced get() = status == Synchronizer.Status.SYNCED

    override fun inflateBinding(layoutInflater: LayoutInflater): FragmentListTransactionsBinding =
        FragmentListTransactionsBinding.inflate(layoutInflater)

    override fun resetInBackground() {
        initializer.new(config.seed, birthday)
        synchronizer = Synchronizer(App.instance, initializer)
    }

    override fun onResetComplete() {
        initTransactionUI()
        startSynchronizer()
        monitorStatus()
    }

    override fun onClear() {
        KtJavaComLayer.Companion.coins[coinNumber].initializer!!.clear()
        val result = KtJavaComLayer.Companion.interDelete(coinNumber)
        twig("result: ${result}")
        synchronizer.stop()
        initializer.clear()
    }

    private fun initTransactionUI() {
        binding.recyclerTransactions.layoutManager =
            LinearLayoutManager(activity, LinearLayoutManager.VERTICAL, false)
        adapter = TransactionAdapter()

        binding.recyclerTransactions.adapter = adapter
        val coinId = "VRSC"
        val coinProtocol = "vrsc"
        val accountHash = "8ccb033c0e48b27ff91e1ab948367e3bbc6921487c97624ed7ad064025e3dc99"
        val host = "light.virtualsoundnw.com"
        val port = 9077
        val numberOfAccounts = 2
        val seed = "wish puppy smile loan doll curve hole maze file ginger hair nose key relax knife witness cannon grab despair throw review deal slush frame"
        val birthdayInt = 12400900
        val birthdayString = "1_240_900"


        coinNumber = KtJavaComLayer.Companion.addCoin(coinId, accountHash, coinProtocol, App.instance, seed.toByteArray(), host, port, seed, birthdayString, birthdayInt, "sapling", numberOfAccounts);


    }

    private fun startSynchronizer() {
        //lifecycleScope.apply {
          //  synchronizer.start(this)
        //}
        //var path = KtJavaComLayer.Companion.getPath(App.instance, "Test")
        var response = KtJavaComLayer.Companion.Initer(App.instance, "cute", coinNumber)
        twig(response)
        response = KtJavaComLayer.Companion.InitClient(App.instance, coinNumber)
        twig(response)
        lifecycleScope.apply {
            response = KtJavaComLayer.Companion.syncronizerstart(App.instance, coinNumber)
            twig(response)
        }

        lifecycleScope.launch {
            //address = KtJavaComLayer.Companion.coins[coinNumber].
            address = synchronizer.getAddress()
            KtJavaComLayer.Companion.coins[coinNumber].synchronizer!!.clearedTransactions.collect { onTransactionsUpdated(it) }
        }
    }

    private fun monitorStatus() {
        KtJavaComLayer.Companion.coins[coinNumber].synchronizer!!.status.collectWith(lifecycleScope, ::onStatus)
        KtJavaComLayer.Companion.coins[coinNumber].synchronizer!!.processorInfo.collectWith(lifecycleScope, ::onProcessorInfoUpdated)
        KtJavaComLayer.Companion.coins[coinNumber].synchronizer!!.progress.collectWith(lifecycleScope, ::onProgress)
        twig(KtJavaComLayer.Companion.coins[coinNumber].syncroProgress.toString())
    }

    private fun onProcessorInfoUpdated(info: CompactBlockProcessor.ProcessorInfo) {
        if (info.isScanning) binding.textInfo.text = "Scanning blocks...${info.scanProgress}%"
    }

    private fun onProgress(i: Int) {
        if (i < 100) binding.textInfo.text = "Downloading blocks...$i%"
        twig(KtJavaComLayer.Companion.coins[coinNumber].syncroProgress.toString())

    }

    private fun onStatus(status: Synchronizer.Status) {
        this.status = status
        binding.textStatus.text = "Status: $status"
        if (isSynced) onSyncComplete()
    }

    private fun onSyncComplete() {
        binding.textInfo.visibility = View.INVISIBLE
    }

    private fun onTransactionsUpdated(transactions: PagedList<ConfirmedTransaction>) {
        twig("got a new paged list of transactions")
        adapter.submitList(transactions)

        // show message when there are no transactions
        if (isSynced) {
            binding.textInfo.apply {
                if (transactions.isEmpty()) {
                    visibility = View.VISIBLE
                    text =
                        "No transactions found. Try to either change the seed words in the" +
                                " DemoConfig.kt file or send funds to this address (tap the FAB to copy it):\n\n $address"
                } else {
                    visibility = View.INVISIBLE
                    text = ""
                }
            }
        }
    }

    override fun onActionButtonClicked() {
        if (::address.isInitialized) copyToClipboard(address)
    }
}
