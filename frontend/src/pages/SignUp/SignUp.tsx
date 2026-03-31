import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import './SignUpPage.css'
import duck from '../../assets/Duck_Image.png'

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
                fName: firstName,
                lName: lastName,
                email: email,
                pass: password
            }
    
            //fetch (will need to change)
            let response = await fetch("http://localhost:8080/users", {
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
                    _id: userData._id //may need to change based on db
                };
            } else {
                return null;
            }
        }
    
        const checkEmail = async() => {
            try {
                const response = await axios.get('http://localhost:5173/controllers/authController', {params: {email: email}}); //will need to change url
                const taken = response.data.isTaken;
                setIsEmailTaken(taken);
                return taken;
            } catch (error) {
                console.error("Failed to check email:", error);
                return true; 
            }
        };
    
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
    
            //check if email already exists
            const isTaken = await checkEmail();
            if(isTaken)
            {
                setErrorMessage("Username is already taken. Try again.");
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
    
                console.log("routing...")
                navigate('./Dashboard/Dashboard');
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
                    <p id="signUpError">Error: {errMessage}</p>
                    )}

                    <form className="signUpForm" onSubmit={newUser}>
                        <div className='UserName'>
                            <input id="signUpFName" onChange={handleFirstNameChange} type="text" placeholder="First Name"/>
                            <br/>
                            <br/>
                            <input id="signUpLName" onChange={handleLastNameChange} type="text" placeholder="Last Name"/>
                            <br/>
                            <br/>
                        </div>
                        <input id="signUpEmail" onChange={handleEmailChange} type="text" placeholder="Email"/>
                        <br/>
                        <br/>
                        <input id="signUpPass" onChange={handlePasswordChange} type="password" placeholder="Password"/>
                        <br/>
                        <br/>
                        <input id="signUpPass2" onChange={handlePassword2Change} type="password" placeholder=" Confirm Password"/>
                        <br/>
                        <br/>
                        <div className="signUpButtons">
                            <div className="loginContainer">
                                <p>Don't have an account?</p>
                                <button id="loginLink"onClick={() => navigate('/Login')} type="button">Login here</button>
                            </div>
                            <button id="signUpSubmit" type="submit">Sign Up</button>
                        </div>
                    </form>
                </main>
                <img id="duckImgSignUp" src={duck} alt="Duck Image" />
            </div>
        </>
    );
};