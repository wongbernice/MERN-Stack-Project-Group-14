import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import './loginPage.css'
import duck from '../../assets/Duck_Image.webp'

export const LoginPage = () =>
{
    const[email, setEmail] = useState("");
    const[password, setPassword] = useState("");
    const[errMessage, setErrorMessage] = useState("");
    const navigate = useNavigate()

    function handleEmailChange(data: ChangeEvent<HTMLInputElement>)
    {
        setEmail(data.target.value);
    }

    function handlePasswordChange(data: ChangeEvent<HTMLInputElement>)
    {
        setPassword(data.target.value);
    }

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault()
        setErrorMessage("");

        if(!email || !password)
        {
            setErrorMessage("All fields are required!");
            return;
        }

        //allows user to login if conditions are met
        axios.post('https://duckydollars.xyz/api/auth/login', {email: email, password: password})
        .then(result => {
            console.log("full login response:", result.data);
            if(result.data.id !== -1)
            {
                localStorage.setItem('_id', result.data.id);
                localStorage.setItem('token', result.data.token);
                localStorage.setItem('isVerified', result.data.isVerified.toString());
                if (result.data.isVerified) {
                    navigate('/dashboard');
                } else {
                    navigate('/verify');
                }
            }
        })
        .catch(err => {
            const errMessage = err.response?.data?.error || "Server Error";
            setErrorMessage(errMessage);
        })
    }

    return(
        <>
            <NavBar />
            <div className="loginDiv">
                <main className="loginMain">
                    <h2 id="loginTitle">Login</h2>

                    {errMessage && (
                        <p id="loginError" role="alert" aria-live='assertive'>Error: {errMessage}</p>
                    )}

                    <form className="loginForm" onSubmit={handleSubmit}>
                        <label htmlFor='loginEmail' id='loginEmailLabel' className='srOnly'></label>
                        <input id="loginEmail" onChange={handleEmailChange} type="email" placeholder="Email" required/>
                        <br/>
                        <br/>
                        <label htmlFor='loginPass' id='loginPassLabel' className='srOnly'></label>
                        <input id="loginPass" onChange={handlePasswordChange} type="password" placeholder="Password" required/>
                        <br/>
                        <br/>
                        <div className="loginButtons">
                            <div className="resetContainer">
                                <p>Forgot password?</p>
                                <Link id='resetLink' to="/resetPassword">Reset it here</Link>
                            </div>
                            <br/>
                            <div className="registerContainer">
                                <p>Don't have an account?</p>
                                <Link id="registerLink" to='/signUp'>Register here</Link>
                            </div>
                            <button id="loginSubmit" type="submit">Log In</button>
                        </div>
                    </form>
                </main>
                <img id="duckImgLogin" src={duck} width="120" height="120" loading="eager" fetchPriority='low' alt="Duck Image" />
            </div>
        </>
    );
};