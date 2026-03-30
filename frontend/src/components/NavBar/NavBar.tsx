import './navBar.css'
import duck from '../../assets/Duck_Image.png'
import { useNavigate, useLocation } from 'react-router-dom';

export const NavBar = () =>
{
    const navigate = useNavigate();
    const location = useLocation();
    const hideLocations = location.pathname === '/' || location.pathname === '/login' || location.pathname === '/signUp';

    const handleLogoClick = () =>
    {
        navigate('/');
    }

    const handleDashClick = () =>
    {
        navigate('/dashboard');
    }

    const handleTransClick = () =>
    {
        navigate('/transactions');
    }

    const handleLogOut = () =>
    {
        navigate('/');
    }

    return(
        <>
            <nav className='navBarNav'>
                <span id="logo" onClick={handleLogoClick}><img id="logoImg" src="../src/assets/Logo.png" alt="Logo"/></span>
                { !hideLocations && (
                    <div className='navBarOptions'>
                        <button id="dashboardLink" onClick={handleDashClick}>Dashboard</button>
                        <button id="transactionsLink" onClick={handleTransClick}>Transactions</button>
                        <button id="logoutBtn">Log Out</button>
                    </div>
                )}
            </nav>
        </>
    );
};