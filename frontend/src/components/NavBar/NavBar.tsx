import './navBar.css'
import { useNavigate, useLocation} from 'react-router-dom';
import { useState } from 'react';
import { AddTransaction } from '../../components/AddTransactions/addTransactions'

export const NavBar = () =>
{
    const navigate = useNavigate();
    const location = useLocation();
    const hideLocations = location.pathname === '/' || location.pathname === '/login' || location.pathname === '/signUp';

    //handles addTransaction popup
    const [isOpen, setIsOpen] = useState(false);
    const togglePopup = () =>
    {
        setIsOpen(!isOpen);
    }

    const handleLogoClick = () =>
    {
        navigate('/dashboard');
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
                <span id="logo" onClick={handleLogoClick}><img id="logoImg" src="../src/assets/Logo.png" alt="Logo"/></span>
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
                        onSubmit={(data) => {
                            togglePopup();
                    }} />
                )}
            </nav>
        </>
    );
};