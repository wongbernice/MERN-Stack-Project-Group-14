import './navBar.css'
import duck from '../../assets/Duck_Image.png'

export const NavBar = () =>
{
    return(
        <>
            <div className='navBarDiv'>
                <h1 id="logo">Ducky D<img id="duckLogo" src={duck} alt="o"/>llars</h1>
            </div>
        </>
    );
};