import axios from 'axios';
import { useState, useEffect, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import { AddTransaction } from '../../components/AddTransactions/addTransactions'
import duck from '../../assets/Duck_Image.png'
import './TransactionsPage.css'

interface Transaction {
    _id: string;
    date: string;
    categoryId:string;
    note:string;
    amount: number;
}

export const TransactionsPage = () =>
{
    const[isOverlay, setIsOverlay] = useState(false);
    const[searchQuery, setSearchQuery] = useState("");
    const[transactions, setTransactions] = useState<Transaction[]>([]);
    const toggleOverlay = () => setIsOverlay(!isOverlay);

    useEffect(() => {
        const getTransactions = async () => {
            const userId = localStorage.getItem('_id');
            if (!userId)
                return;

            try {
                const response = await axios.get(`http://67.205.159.14:5000/api/transactions?userId=${userId}`);
                setTransactions(response.data.transactions);
            } catch (error){
                console.log("error getting transactions: ", error);
            }
        };
        getTransactions();
    }, []);

    return(
        <>
            <NavBar />
            <div className='transactionsDiv'>
                <div className='wrapper'>
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

                        <p id='totalTrans'>{transactions.length} Transactions</p>

                        <div className='searchPanel'>
                            <form className='searchForm'>
                                <input id='searchInput' type='search' placeholder='Search' value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)}/>
                                <button id='searchBtn' type='submit'>🔍</button>
                            </form>
                            <button id='editBtn'>Edit ★</button>
                        </div>

                        <div className='transactionsList'>
                            <div className='listLabels'>
                                <p id="dateL">Date</p>
                                <p id="catL">Category</p>
                                <p id="noteL">Notes</p>
                                <p id="amountL">Amount</p>
                            </div>

                            {transactions.map((transaction) => (
                                <div className='transaction' key={transaction._id}>
                                        <p>{transaction.date}</p>
                                        <p>{transaction.categoryId}</p>
                                        <p>{transaction.note}</p>
                                        <p>{transaction.amount}</p>
                                </div>
                            ))}
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
            </div>
            <img id="duckImgTrans" src={duck} alt="Duck Image" />
        </>
    );
};