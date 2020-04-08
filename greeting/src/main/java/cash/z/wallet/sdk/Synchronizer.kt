package cash.z.wallet.sdk

import androidx.paging.PagedList
import cash.z.wallet.sdk.block.CompactBlockProcessor
import cash.z.wallet.sdk.block.CompactBlockProcessor.WalletBalance
import cash.z.wallet.sdk.entity.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow

/**
 * Primary interface for interacting with the SDK. Defines the contract that specific
 * implementations like [MockSynchronizer] and [SdkSynchronizer] fulfill. Given the language-level
 * support for coroutines, we favor their use in the SDK and incorporate that choice into this
 * contract.
 */
interface Synchronizer {

    //
    // Lifecycle
    //

    /**
     * Starts this synchronizer within the given scope.
     *
     * @param parentScope the scope to use for this synchronizer, typically something with a
     * lifecycle such as an Activity. Implementations should leverage structured concurrency and
     * cancel all jobs when this scope completes.
     *
     * @return an instance of the class so that this function can be used fluidly.
     */
    fun start(parentScope: CoroutineScope? = null): Synchronizer

    /**
     * Stop this synchronizer. Implementations should ensure that calling this method cancels all
     * jobs that were created by this instance.
     */
    fun stop()


    //
    // Flows
    //

    /* Status */

    /**
     * A flow of values representing the [Status] of this Synchronizer. As the status changes, a new
     * value will be emitted by this flow.
     */
    val status: Flow<Status>

    /**
     * A flow of progress values, typically corresponding to this Synchronizer downloading blocks.
     * Typically, any non- zero value below 100 indicates that progress indicators can be shown and
     * a value of 100 signals that progress is complete and any progress indicators can be hidden.
     */
    val progress: Flow<Int>

    /**
     * A flow of processor details, updated every time blocks are processed to include the latest
     * block height, blocks downloaded and blocks scanned. Similar to the [progress] flow but with a
     * lot more detail.
     */
    val processorInfo: Flow<CompactBlockProcessor.ProcessorInfo>

    //used to store the blockprocessor
    val blockProcessor: CompactBlockProcessor

    /**
     * A stream of balance values, separately reflecting both the available and total balance.
     */
    val balances: Flow<WalletBalance>

    /* Transactions */

    /**
     * A flow of all the outbound pending transaction that have been sent but are awaiting
     * confirmations.
     */
    val pendingTransactions: Flow<List<PendingTransaction>>

    /**
     * A flow of all the transactions that are on the blockchain.
     */
    val clearedTransactions: Flow<PagedList<ConfirmedTransaction>>

    /**
     * A flow of all transactions related to sending funds.
     */
    val sentTransactions: Flow<PagedList<ConfirmedTransaction>>

    /**
     * A flow of all transactions related to receiving funds.
     */
    val receivedTransactions: Flow<PagedList<ConfirmedTransaction>>


    //
    // Operations
    //

    /**
     * Gets the address for the given account.
     *
     * @param accountId the optional accountId whose address is of interest. By default, the first
     * account is used.
     *
     * @return the address for the given account.
     */
    suspend fun getAddress(accountId: Int = 0): String

    /**
     * Sends zatoshi.
     *
     * @param spendingKey the key associated with the notes that will be spent.
     * @param zatoshi the amount of zatoshi to send.
     * @param toAddress the recipient's address.
     * @param memo the optional memo to include as part of the transaction.
     * @param fromAccountIndex the optional account id to use. By default, the first account is used.
     *
     * @return a flow of PendingTransaction objects representing changes to the state of the
     * transaction. Any time the state changes a new instance will be emitted by this flow. This is
     * useful for updating the UI without needing to poll. Of course, polling is always an option
     * for any wallet that wants to ignore this return value.
     */
    fun sendToAddress(
        spendingKey: String,
        zatoshi: Long,
        toAddress: String,
        memo: String = "",
        fromAccountIndex: Int = 0
    ): Flow<PendingTransaction>


    /**
     * Returns true when the given address is a valid z-addr. Invalid addresses will throw an
     * exception. Valid z-addresses have these characteristics: //TODO copy info from related ZIP
     *
     * @param address the address to validate.
     *
     * @return true when the given address is a valid z-addr.
     *
     * @throws RuntimeException when the address is invalid.
     */
    suspend fun isValidShieldedAddr(address: String): Boolean

    /**
     * Returns true when the given address is a valid t-addr. Invalid addresses will throw an
     * exception. Valid t-addresses have these characteristics: //TODO copy info from related ZIP
     *
     * @param address the address to validate.
     *
     * @return true when the given address is a valid t-addr.
     *
     * @throws RuntimeException when the address is invalid.
     */
    suspend fun isValidTransparentAddr(address: String): Boolean

    /**
     * Validates the given address, returning information about why it is invalid. This is a
     * convenience method that combines the behavior of [isValidShieldedAddr] and
     * [isValidTransparentAddr] into one call so that the developer doesn't have to worry about
     * handling the exceptions that they throw. Rather, exceptions are converted to
     * [AddressType.Invalid] which has a `reason` property describing why it is invalid.
     *
     * @param address the address to validate.
     *
     * @return an instance of [AddressType] providing validation info regarding the given address.
     */
    suspend fun validateAddress(address: String): AddressType

    /**
     * Attempts to cancel a transaction that is about to be sent. Typically, cancellation is only
     * an option if the transaction has not yet been submitted to the server.
     *
     * @param transaction the transaction to cancel.
     *
     * @return true when the cancellation request was successful. False when it is too late.
     */
    suspend fun cancelSpend(transaction: PendingTransaction): Boolean


    //
    // Error Handling
    //

    /**
     * Gets or sets a global error handler. This is a useful hook for handling unexpected critical
     * errors.
     *
     * @return true when the error has been handled and the Synchronizer should attempt to continue.
     * False when the error is unrecoverable and the Synchronizer should [stop].
     */
    var onCriticalErrorHandler: ((Throwable?) -> Boolean)?

    /**
     * An error handler for exceptions during processing. For instance, a block might be missing or
     * a reorg may get mishandled or the database may get corrupted.
     *
     * @return true when the error has been handled and the processor should attempt to continue.
     * False when the error is unrecoverable and the processor should [stop].
     */
    var onProcessorErrorHandler: ((Throwable?) -> Boolean)?

    /**
     * An error handler for exceptions while submitting transactions to lightwalletd. For instance,
     * a transaction may get rejected because it would be a double-spend or the user might lose
     * their cellphone signal.
     *
     * @return true when the error has been handled and the sender should attempt to resend. False
     * when the error is unrecoverable and the sender should [stop].
     */
    var onSubmissionErrorHandler: ((Throwable?) -> Boolean)?

    /**
     * A callback to invoke whenever a chain error is encountered. These occur whenever the
     * processor detects a missing or non-chain-sequential block (i.e. a reorg).
     */
    var onChainErrorHandler: ((Int, Int) -> Any)?

    /**
     * Represents the status of this Synchronizer, which is useful for communicating to the user.
     */
    enum class Status {
        /**
         * Indicates that [stop] has been called on this Synchronizer and it will no longer be used.
         */
        STOPPED,

        /**
         * Indicates that this Synchronizer is disconnected from its lightwalletd server.
         * When set, a UI element may want to turn red.
         */
        DISCONNECTED,

        /**
         * Indicates that this Synchronizer is actively downloading new blocks from the server.
         */
        DOWNLOADING,

        /**
         * Indicates that this Synchronizer is actively validating new blocks that were downloaded
         * from the server. Blocks need to be verified before they are scanned. This confirms that
         * each block is chain-sequential, thereby detecting missing blocks and reorgs.
         */
        VALIDATING,

        /**
         * Indicates that this Synchronizer is actively decrypting new blocks that were downloaded
         * from the server.
         */
        SCANNING,

        /**
         * Indicates that this Synchronizer is fully up to date and ready for all wallet functions.
         * When set, a UI element may want to turn green. In this state, the balance can be trusted.
         */
        SYNCED
    }

    /**
     * Represents the types of addresses, either Shielded, Transparent or Invalid.
     */
    sealed class AddressType {
        /**
         * Marker interface for valid [AddressType] instances.
         */
        interface Valid

        /**
         * An instance of [AddressType] corresponding to a valid z-addr.
         */
        object Shielded : Valid, AddressType()

        /**
         * An instance of [AddressType] corresponding to a valid t-addr.
         */
        object Transparent : Valid, AddressType()

        /**
         * An instance of [AddressType] corresponding to an invalid address.
         *
         * @param reason a descrption of why the address was invalid.
         */
        class Invalid(val reason: String = "Invalid") : AddressType()

        /**
         * A convenience method that returns true when an instance of this class is invalid.
         */
        val isNotValid get() = this !is Valid
    }

}
