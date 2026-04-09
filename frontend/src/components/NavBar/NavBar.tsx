import axios from 'axios';
import './navBar.css';
import { useNavigate, useLocation} from 'react-router-dom';
import { useState, useEffect } from 'react';
import { AddTransaction } from '../../components/AddTransactions/addTransactions';
import logo from '../../assets/Logo.png';

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

export const NavBar = () =>
{
    const navigate = useNavigate();
    const location = useLocation();
    const hideLocations = location.pathname === '/' || location.pathname === '/login' || location.pathname === '/signUp' || location.pathname === '/verify' || location.pathname === '/resetPassword';
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);

    //handles addTransaction popup
    const [isOpen, setIsOpen] = useState(false);
    const togglePopup = () =>
    {
        setIsOpen(!isOpen);
    }

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
                headers: { Authorization: `Bearer ${token}` }
            });
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
        getCategories();
    }, []);

    const handleAddTrans = async (transactionInfo: any) => {
        const token = localStorage.getItem('token');
        try {
            await axios.post('https://duckydollars.xyz/api/transactions', transactionInfo, {
                headers: { Authorization: `Bearer ${token}` }
            });
            await getTransactions();
            togglePopup();
        } catch (error){
            console.error("error saving transaction:", error);
        }
    };

    const handleLogoClick = () =>
    {
        const userId = localStorage.getItem('_id');
        const isVerified = localStorage.getItem('isVerified');

        if (!userId || userId === "null" || userId === "undefined") {
            navigate('/');
            return;
        } else if (isVerified !== 'true') {
            navigate('/verify');
        } else {
            navigate('/dashboard');
        }
    }

    const handleDashClick = () =>
    {
        navigate('/dashboard');
    }

    const handleTransClick = () =>
    {
        navigate('/transactions');
    }

    const handleBudgetClick = () =>
    {
        navigate('/budget')
    }

    const handleLogOut = () =>
    {
        localStorage.removeItem('_id');
        localStorage.clear();
        navigate('/login');
    }

    return(
        <>
            <nav className='navBarNav'>
                <span id="logo" onClick={handleLogoClick}><img id="logoImg" src={logo} alt="Logo"/></span>
                { !hideLocations && (
                    <div className='navBarOptions'>
                        <div className='dropdownContainer'>
                            <button id="options">Options▼</button>
                            <div className='dropdownMenu'>
                                <button id="dashboardLink" onClick={handleDashClick}>Dashboard</button>
                                <button id="budgetLink" onClick={handleBudgetClick}>Budget</button>
                                <button id="transactionsLink" onClick={handleTransClick}>Transactions</button>
                            </div>
                        </div>
                        <button id="addTransactionBtn" onClick={() => setIsOpen(true)}>Add Transaction</button>
                        <button id="logoutBtn" onClick={handleLogOut}>Log Out</button>
                    </div>
                )}

                {isOpen && (
                    <AddTransaction 
                        onClose={togglePopup} 
                        onSubmit={handleAddTrans}
                    />
                )}
            </nav>
        </>
    );
};