import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import './SignUpPage.css'
import duck from '../../assets/Duck_Image.webp'

export const SignUpPage = () =>
{
    const[firstName, setFirstName] = useState("");
    const[lastName, setLastName] = useState("");
    const[email, setEmail] = useState("");
    const[isEmailTaken, setIsEmailTaken] = useState(false);
    const[password, setPassword] = useState("");
    const[password2, setPassword2] = useState("");
    const[errMessage, setErrorMessage] = useState("");
    const navigate = useNavigate()

    async function addNewUser()
        {
            let doc = {
                First: firstName,
                Last: lastName,
                email: email,
                password: password
            }
    
            try 
            {
                //fetch
                let response = await fetch("https://duckydollars.xyz/api/auth/register", {
                    method: "POST",
                    body: JSON.stringify(doc),
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    }
                });
        
                //check if response was successful
                if(response.ok){
                    const userData = await response.json();
                    return {
                        _id: userData.id
                    };
                } else {
                    const errorData = await response.json();
                    setErrorMessage(errorData.error || "Account creation error");
                    return null;
                }
            } catch (error) {
                setErrorMessage("Could not connect to server.");
                return null;
            }
        }
    
        //redirect user to the catalog page
        async function newUser(event: React.FormEvent<HTMLFormElement>)
        {
            event.preventDefault();
            setErrorMessage("");
    
            //check if any fields are empty
            if(!firstName || !lastName || !email || !password || !password2)
            {
                setErrorMessage("All fields are required!");
                return;
            }

            //ensure passwords match
            if(password !== password2){
                setErrorMessage("Passwords do not match. Please try again.");
                return;
            }
    
            //stores userType and user id in local storage
            const userData = await addNewUser();
            if(typeof userData === 'object' && userData !== null) 
            {
                localStorage.setItem('_id', userData._id);
                localStorage.setItem("email", email);
                localStorage.setItem('isVerified', 'false');
                navigate('/verify');
            } else {
                setErrorMessage("Account creation error");
            }
        }
    
        function handleFirstNameChange(data: ChangeEvent<HTMLInputElement>)
        {
            setFirstName(data.target.value);
        }
    
        function handleLastNameChange(data: ChangeEvent<HTMLInputElement>)
        {
            setLastName(data.target.value);
        }

        function handleEmailChange(data: ChangeEvent<HTMLInputElement>)
        {
            setEmail(data.target.value);
            setIsEmailTaken(false);
            setErrorMessage("");
        }   
    
        function handlePasswordChange(data: ChangeEvent<HTMLInputElement>)
        {
            setPassword(data.target.value);
        }
    
        function handlePassword2Change(data: ChangeEvent<HTMLInputElement>)
        {
            setPassword2(data.target.value);
        }

    return(
        <>
            <NavBar />
            <div className="signUpDiv">
                <main className="signUpMain">
                    <h2 id="signUpTitle">Sign Up</h2>

                    {errMessage && (
                        <p id="signUpError" role="alert" aria-live='assertive'>Error: {errMessage}</p>
                    )}

                    <form className="signUpForm" onSubmit={newUser}>
                        <div className='UserName'>
                            <label htmlFor='signUpFName' id='signUpFNameLabel' className='srOnly'></label>
                            <input id="signUpFName" onChange={handleFirstNameChange} type="text" placeholder="First Name"/>
                            <br/>
                            <br/>
                            <label htmlFor='signUpLName' id='signUpLNameLabel' className='srOnly'></label>
                            <input id="signUpLName" onChange={handleLastNameChange} type="text" placeholder="Last Name"/>
                            <br/>
                            <br/>
                        </div>
                        <label htmlFor='signUpEmail' id='signUpEmailLabel' className='srOnly'></label>
                        <input id="signUpEmail" onChange={handleEmailChange} type="text" placeholder="Email"/>
                        <br/>
                        <br/>
                        <label htmlFor='signUpPass' id='signUpPassLabel' className='srOnly'></label>
                        <input id="signUpPass" onChange={handlePasswordChange} type="password" placeholder="Password"/>
                        <br/>
                        <br/>
                        <label htmlFor='signUpPass2' id='signUpPass2Label' className='srOnly'></label>
                        <input id="signUpPass2" onChange={handlePassword2Change} type="password" placeholder=" Confirm Password"/>
                        <br/>
                        <br/>
                        <div className="signUpButtons">
                            <div className="loginContainer">
                                <p>Already have an account?</p>
                                <Link id="loginLink" to='/login' type="button">Login here</Link>
                            </div>
                            <button id="signUpSubmit" type="submit">Sign Up</button>
                        </div>
                    </form>
                </main>
                <img id="duckImgSignUp" src={duck} width="120" height="120" loading="eager" fetchPriority='low' alt="Duck Image" />
            </div>
        </>
    );
};