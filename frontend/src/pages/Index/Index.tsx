import { useNavigate } from 'react-router-dom'
import { NavBar } from '../../components/NavBar/NavBar'
import './IndexPage.css'
import duck from '../../assets/Duck_Image.webp'

export const Index = () => 
{
    const navigate = useNavigate();
    return(
        <>
            <NavBar />
            <main className='indexMain'>
                <div className='words'>
                    <p id="header">Keep Your Ducks In A Row,<br/> and Your Budget Too</p>
                    <p id="body">
                        Ducky Dollars helps you set budgets and monitor your spending by
                        <br/>
                        category, so you can stay on track towards you financial goals.
                    </p>
                </div>
                
                <div className="indexButtons">
                    <button id="existingUser" type="button" onClick={() => navigate('/login')}>Login</button>
                    <button id="newUser" type="button" onClick={() => navigate('/signUp')}>Sign Up</button>
                </div>
            </main>
            <img id="duckImgIndex" src={duck} alt="Duck Image" />
        </>
    );
};