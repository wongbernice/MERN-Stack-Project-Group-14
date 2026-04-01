import './addTransactionsPage.css'

//defining items need to close the popup/overlay
interface OverlayItems {
    onClose: () => void;
    onSubmit: (data: any) => void;
}

export const AddTransaction = ({onClose, onSubmit}: OverlayItems) => 
{
    return(
        <>
            <div className="overlay" onClick={onClose}>
                <div className='formCard' onClick={(e) => e.stopPropagation()}>
                    <button id="closeForm" onClick={onClose}>X</button>
                    <h3 id='addTitle'>Add Transaction</h3>
                    <form className='newTransaction'>
                        <input id='transDate' type='date' placeholder='Date' required/>
                        <br/>
                        <input id='transCategory' type='text' placeholder='Category' required/>
                        <br/>
                        <input id='transAmount' type='number' placeholder='Amount' required/>
                        <br/>
                        <textarea id='transNote' placeholder='Notes' rows={4} required/>
                        <br/>
                        <button id='newTransSubmit' type='submit' onClick={onSubmit}>Add</button>
                    </form>
                </div>
            </div>
        </>
    )
}