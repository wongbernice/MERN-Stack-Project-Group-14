import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import './loginPage.css'
import duck from '../../assets/Duck_Image.png'

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

        //allows user to login if conditions are met (may need to change later)
        axios.post('http://localhost:5173/', {email: email, pass: password}) //will need to change url
        .then(result => {
            if(result.data.status === "Success")
            {
                const userID = result.data.userID;
                if(userID)
                {
                    localStorage.setItem('_id', userID);
                    navigate('./Dashboard/Dashboard');
                }
            }
        })
        .catch(err => {
            console.log(err);
            if (err.response){
                if(err.response.status === 401) {
                    const failMessage = err.response.data;
                    setErrorMessage(failMessage);
                }
            } else {
                console.log("Network error: ", err);
                setErrorMessage("A network or server error occurred. Please try again.");
            }
        })
    }

    return(
        <>
            <NavBar />
            <div className="loginDiv">
                <main className="loginMain">
                    <h2 id="loginTitle">Login</h2>

                    {errMessage && (
                    <p id="loginError">Error: {errMessage}</p>
                    )}

                    <form className="loginForm" onSubmit={handleSubmit}>
                        <input id="loginEmail" onChange={handleEmailChange} type="email" placeholder="Email" required/>
                        <br/>
                        <br/>
                        <input id="loginPass" onChange={handlePasswordChange} type="password" placeholder="Password" required/>
                        <br/>
                        <br/>
                        <div className="loginButtons">
                            <div className="registerContainer">
                                <p>Don't have an account?</p>
                                <button id="registerLink"onClick={() => navigate('/signUp')} type="button">Register here</button>
                            </div>
                            <button id="loginSubmit" type="submit">Log In</button>
                        </div>
                    </form>
                </main>
                <img id="duckImgLogin" src={duck} alt="Duck Image" />
            </div>
        </>
    );
};