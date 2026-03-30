import './navBar.css'
import duck from '../../assets/Duck_Image.png'
import { useNavigate } from 'react-router-dom';

export const NavBar = () =>
{
    const navigate = useNavigate();
    const handleLogoClick = () =>
    {
        navigate('/');
    }

    return(
        <>
            <div className='navBarDiv'>
                <span id="logo" onClick={handleLogoClick}><img id="logoImg" src="../src/assets/Logo.png" alt="Logo"/></span>
            </div>
        </>
    );
};