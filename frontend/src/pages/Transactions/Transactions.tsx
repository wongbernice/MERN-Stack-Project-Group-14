import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import { AddTransaction } from '../../components/AddTransactions/addTransactions'
import duck from '../../assets/Duck_Image.png'
import './TransactionsPage.css'

export const TransactionsPage = () =>
{
    const[isOverlay, setIsOverlay] = useState(false);
    const[searchQuery, setSearchQuery] = useState("");
    const toggleOverlay = () => setIsOverlay(!isOverlay);


    return(
        <>
            <NavBar />
            <div className='transactionsDiv'>
                <h2 id='transactionsTitle'>Transactions</h2>

                
                <main className='transactionsMain'>
                    <div className='topPanel'>
                        <p id='totalMoneyLabel'>Total: {/* Get total from api*/}</p>
                        <div className='topPanelBtns'>
                            <button id='filterBtn'>Filter▼</button>
                            <button id='sortBtn'>Sort By ▼</button>
                            <button id='addTransBtn' onClick={toggleOverlay}>Add Transaction</button>
                        </div>
                    </div>

                    <p id='totalTrans'>Temp{/* Get total # of transactions from api */}</p>

                    <div className='searchPanel'>
                        <form className='searchForm'>
                            <input id='searchInput' type='search' placeholder='Search' value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)}/>
                            <button id='searchBtn' type='submit'>🔍</button>
                        </form>
                        <button id='editBtn'>Edit ★</button>
                    </div>

                    <div className='transactionsList'>
                        <div className='listLabels'>
                            <p>Date</p>
                            <p>Category</p>
                            <p>Notes</p>
                            <p>Amount</p>
                        </div>

                        <div className='transaction'>
                            {/* get each transaction from api */}
                        </div>
                    </div>
                    

                    {isOverlay && (
                        <AddTransaction 
                            onClose={toggleOverlay} 
                            onSubmit={(data) => {
                                toggleOverlay();
                        }} />
                    )}

                </main>
            </div>
            <img id="duckImgTrans" src={duck} alt="Duck Image" />
        </>
    );
};