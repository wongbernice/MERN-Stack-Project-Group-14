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
                <span id="logo" onClick={handleLogoClick}>Ducky D<img id="duckLogo" src={duck} alt="o"/>llars</span>
            </div>
        </>
    );
};