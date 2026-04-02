import axios from 'axios';
import { useState, useEffect, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import { AddTransaction } from '../../components/AddTransactions/addTransactions'
import duck from '../../assets/Duck_Image.png'
import './TransactionsPage.css'

//defining transaction
interface Transaction {
    _id: string;
    date: string;
    categoryId:string;
    note:string;
    amount: number;
}

//defining category 
interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
    userId: string;
}

export const TransactionsPage = () =>
{
    const[isOverlay, setIsOverlay] = useState(false);
    const[searchQuery, setSearchQuery] = useState("");
    const[transactions, setTransactions] = useState<Transaction[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);
    const toggleOverlay = () => setIsOverlay(!isOverlay);

   
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

    const getCategories = async () => {
        const userId = localStorage.getItem('_id');
        if(!userId)
            return;

        try {
            const response = await fetch(`http://67.205.159.14:5000/api/categories?userId=${userId}`);
            const data = await response.json();

            if(data.categories)
            {
                setCategories(data.categories);
            }
        } catch (error){
            console.log("error getting categories: ", error);
        }
    };
        
    useEffect(() => {
        getTransactions();
        getCategories();
    }, []);

    const handleAddTrans = async (transactionInfo: any) => {
        try {
            await axios.post('http://67.205.159.14:5000/api/transactions', transactionInfo);
            await getTransactions();
            toggleOverlay();
        } catch (error){
            console.error("error saving transaction:", error);
        }
    };

    const getCatName = (id: string) => {
        const cat = categories.find((cat: Category) => cat._id === id);
        return cat ? cat.name : "unknown";
    }

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
                                        <p id="dateR">{transaction.date}</p>
                                        <p id="catR">{getCatName(transaction.categoryId)}</p>
                                        <p id="noteR">{transaction.note}</p>
                                        <p id="amountR">${transaction.amount}</p>
                                </div>
                            ))}
                        </div>
                        

                        {isOverlay && (
                            <AddTransaction 
                                onClose={toggleOverlay} 
                                onSubmit={handleAddTrans}
                            />
                        )}

                    </main>
                </div>
            </div>
            <img id="duckImgTrans" src={duck} alt="Duck Image" />
        </>
    );
};