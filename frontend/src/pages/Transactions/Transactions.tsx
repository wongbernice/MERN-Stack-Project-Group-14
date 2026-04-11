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
    const[categories, setCategories] = useState<Category[]>([]);
    const[editTransaction, setEditTransaction] = useState<Transaction | null>(null);
    const[selectedCat, setSelectedCat] = useState<string>("");
    const[isFilter, setIsFilter] = useState(false);
    const[sortType, setSortType] = useState("recentlyAdded");
    const[isSort, setIsSort] = useState(false);
    const toggleOverlay = () => setIsOverlay(!isOverlay);
    const toggleEdit = () => setIsEditClicked(!isEditClicked);
    const toggleSort = () => setIsSort(!isSort);

   
    const getTransactions = async () => {
        const userId = localStorage.getItem('_id');
        const token = localStorage.getItem('token');
        if (!userId || !token) return;

        try {
            const response = await axios.get(`https://duckydollars.xyz/api/transactions?userId=${userId}`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setTransactions(response.data.transactions);
        } catch (error){
            console.log("error getting transactions: ", error);
        }
    };

    const getCategories = async () => {
        const userId = localStorage.getItem('_id');
        const token = localStorage.getItem('token');
        if (!userId || !token) return;

        try {
            const response = await fetch(`https://duckydollars.xyz/api/categories?userId=${userId}`, {
                    headers: {
                    Authorization: `Bearer ${token}`
                }
            }

            );
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
        const token = localStorage.getItem('token');
        try {
            await axios.post('https://duckydollars.xyz/api/transactions', transactionInfo, {
                headers: { Authorization: `Bearer ${token}` }
            });
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
        const token = localStorage.getItem('token');
        try {
            await axios.put(`https://duckydollars.xyz/api/transactions/${editTransaction?._id}`, updatedData, {
                headers: { Authorization: `Bearer ${token}` }
            });
            await getTransactions();
            setEditTransaction(null);
            setIsOverlay(false);
        } catch (error) {
            console.log("update failed: ", error);
        }
    }

    const handleDelete = async (id: string) => {
        if(!window.confirm("Are you sure you want to delete this transaction?")) return;
        const token = localStorage.getItem('token');
        try {
            await axios.delete(`https://duckydollars.xyz/api/transactions/${id}`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setTransactions(transactions.filter(t => t._id !== id));
            getCategories();
        } catch (error) {
            alert("Failed to delete transaction.");
        }
    }

    let processedTrans = transactions.filter(t => t.note.toLowerCase().includes(searchQuery.toLowerCase()));

    if(selectedCat) 
    {
        processedTrans = processedTrans.filter(t => t.categoryId === selectedCat);
    }

    //sort based on the selected type
    processedTrans.sort((a,b) => {
        switch (sortType) 
        {
            case "recentlyAdded":
                return parseInt(b._id.substring(0, 8), 16) - parseInt(a._id.substring(0, 8), 16);
            case "dateDesc":
                return new Date(b.date).getTime()-new Date(a.date).getTime();
            case "dateAsc":
                return new Date(a.date).getTime()-new Date(b.date).getTime();
            case "amountHigh":
                return (Number(b.amount) || 0) - (Number(a.amount) || 0);
            case "amountLow":
                return (Number(a.amount) || 0) - (Number(b.amount) || 0);
            case "category":
                return getCatName(a.categoryId).localeCompare(getCatName(b.categoryId));
            default:
                return 0;
        }
    })

    //get filtered total
    const filteredTotal = processedTrans.reduce((sum, t)=> {
        return sum + (Number(t.amount) || 0);
    },0);

    return(
        <>
            <NavBar />
            <div className='transactionsDiv'>
                <div className='wrapper'>
                    <h2 id='transactionsTitle'>Transactions</h2>

                    <main className='transactionsMain'>
                        <div className='topPanel'>
                            <p id='totalMoneyLabel'>Total: ${(selectedCat ? filteredTotal : totalAmount).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}</p>
                            <div className='topPanelBtns'>
                                <div className='filterContainer'>
                                    <button id='filterBtn' onClick={()=>setIsFilter(!isFilter)}>{selectedCat ? 'Filter Active' : 'Filter ▼'}</button>

                                    {isFilter && (
                                        <ul className='filterDropdown'>
                                            {categories.map(cat => (
                                                <li key={cat._id} onClick={()=> {setSelectedCat(cat._id); setIsFilter(false);}}>{cat.name}</li>
                                            ))}

                                            {selectedCat && (
                                                <button id='clearFilter' onClick={()=>{setSelectedCat(""); setIsFilter(false);}}>Clear</button>
                                            )}
                                        </ul>
                                    )}
                                </div>
                                
                                <div className='sortContainer'>
                                    <button id='sortBtn' onClick={toggleSort}>Sort By ▼</button>

                                    {isSort && (
                                        <ul className='sortDropdown'>
                                            <li onClick={() => { setSortType("recentlyAdded"); setIsSort(false); }}>
                                                Recently Added
                                            </li>
                                            <li onClick={() => { setSortType("dateDesc"); setIsSort(false); }}>
                                                Date: Newest to Oldest
                                            </li>
                                            <li onClick={() => { setSortType("dateAsc"); setIsSort(false); }}>
                                                Date: Oldest to Newest
                                            </li>
                                            <li onClick={() => { setSortType("amountHigh"); setIsSort(false); }}>
                                                Amount: High to Low
                                            </li>
                                            <li onClick={() => { setSortType("amountLow"); setIsSort(false); }}>
                                                Amount: Low to High
                                            </li>
                                            <li onClick={() => { setSortType("category"); setIsSort(false); }}>
                                                Category
                                            </li>
                                        </ul>
                                    )}
                                </div>
                                
                                <button id='addTransBtn' onClick={toggleOverlay}>Add Transaction</button>
                            </div>
                        </div>

                        <div className='midTransWrapper'>
                            <div className='middlePanel'>
                                <p id='totalTrans'>{processedTrans.length} Transactions</p>
                                <button id='editBtn' onClick={toggleEdit}>Edit ★</button>
                            </div>

                            <div className='transactionsList'>
                                <table className='transactions'>
                                    <thead>
                                        <tr>
                                            <th>Date</th>
                                            <th>Category</th>
                                            <th>Note</th>
                                            <th>Amount</th>
                                            <th></th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {processedTrans.map((transaction) => (
                                            <tr className='transaction' key={transaction._id}>
                                                <td id="dateR">{transaction.date}</td>
                                                <td id="catR">{getCatName(transaction.categoryId)}</td>
                                                <td id="noteR">{transaction.note}</td>
                                                <td id="amountR">${transaction.amount}</td>
                                                <td id="btnTrans">
                                                    {isEditClicked && (
                                                        <button id="editBtnT" onClick={() => handleEditClick(transaction)}>
                                                            <img id="editIcon" src={editIcon} alt="Edit Icon"/>
                                                        </button>
                                                    )}

                                                    {isEditClicked && (
                                                        <button id="deleteBtnT" onClick={() => handleDelete(transaction._id)}>
                                                            <img id="deleteIcon" src={deleteIcon} alt="Delete Icon"/>
                                                        </button>
                                                    )}
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
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