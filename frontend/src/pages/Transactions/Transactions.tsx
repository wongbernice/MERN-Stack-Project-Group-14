import axios from 'axios';
import { useState, useEffect, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar';
import { AddTransaction } from '../../components/AddTransactions/addTransactions';
import deleteIcon from '../../assets/deleteIcon.png';
import editIcon from '../../assets/editIcon.png';
import './TransactionsPage.css';

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
    const[isEditClicked, setIsEditClicked] = useState(false);
    const[searchQuery, setSearchQuery] = useState("");
    const[transactions, setTransactions] = useState<Transaction[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);
    const [editTransaction, setEditTransaction] = useState<Transaction | null>(null);
    const toggleOverlay = () => setIsOverlay(!isOverlay);
    const toggleEdit = () => setIsEditClicked(!isEditClicked);

   
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

    //get total for all transactions
    const totalAmount = transactions.reduce((sum, transaction) => {
        return sum + (Number(transaction.amount) || 0);
    }, 0);

    const handleEditClick = (transaction: Transaction) =>
    {
        setEditTransaction(transaction);
        setIsOverlay(true);
    }

    const handleEdit = async (updatedData: any) => {
         try {
            await axios.put(`http://67.205.159.14:5000/api/transactions/${editTransaction?._id}`, updatedData);
            await getTransactions();
            setEditTransaction(null);
            setIsOverlay(false);
        } catch (error) {
            console.log("update failed: ", error);
        }
    }

    const handleDelete = async (id: string) => {
        if(!window.confirm("Are you sure you want to delete this transaction?")) return;

        try {
            await axios.delete(`http://67.205.159.14:5000/api/transactions/${id}`);
            setTransactions(transactions.filter(t => t._id !== id));
            getCategories();
        } catch (error) {
            alert("Failed to delete transaction.");
        }
    }

    return(
        <>
            <NavBar />
            <div className='transactionsDiv'>
                <div className='wrapper'>
                    <h2 id='transactionsTitle'>Transactions</h2>

                    <main className='transactionsMain'>
                        <div className='topPanel'>
                            <p id='totalMoneyLabel'>Total: ${totalAmount.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}</p>
                            <div className='topPanelBtns'>
                                <button id='filterBtn'>Filter▼</button>
                                <button id='sortBtn'>Sort By ▼</button>
                                <button id='addTransBtn' onClick={toggleOverlay}>Add Transaction</button>
                            </div>
                        </div>

                        <div className='midTransWrapper'>
                            <div className='middlePanel'>
                                <p id='totalTrans'>{transactions.length} Transactions</p>
                                <button id='editBtn' onClick={toggleEdit}>Edit ★</button>
                            </div>

                            <div className='transactionsList'>
                                <table className='transactions'>
                                    <tr>
                                        <th>Date</th>
                                        <th>Category</th>
                                        <th>Note</th>
                                        <th>Amount</th>
                                        <th style={{visibility:'hidden'}}>Edit</th>
                                        <th style={{visibility:'hidden'}}>Delete</th>
                                    </tr>
                                    {transactions.map((transaction) => (
                                        <tr className='transaction' key={transaction._id}>
                                            <td id="dateR">{transaction.date}</td>
                                            <td id="catR">{getCatName(transaction.categoryId)}</td>
                                            <td id="noteR">{transaction.note}</td>
                                            <td id="amountR">${transaction.amount}</td>
                                            <td id="editBtnTrans">
                                                {isEditClicked && (
                                                     <button id="editBtnT" onClick={() => handleEditClick(transaction)}>
                                                        <img id="editIcon" src={editIcon} alt="Edit Icon"/>
                                                    </button>
                                                )}
                                            </td>
                                            <td id="deleteBtnTrans">
                                                {isEditClicked && (
                                                    <button id="deleteBtnT" onClick={() => handleDelete(transaction._id)}>
                                                        <img id="deleteIcon" src={deleteIcon} alt="Delete Icon"/>
                                                    </button>
                                                )}
                                            </td>
                                        </tr>
                                    ))}
                                </table>
                            </div>
                        </div>
                    
                        {isOverlay && (
                            <AddTransaction 
                                onClose={() => {setIsOverlay(false) ; setEditTransaction(null); }} 
                                onSubmit={editTransaction ? handleEdit : handleAddTrans}
                                initialData={editTransaction}
                            />
                        )}
                    </main>
                </div>
            </div>
        </>
    );
};