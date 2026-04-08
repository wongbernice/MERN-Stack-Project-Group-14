import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import './ResetPasswordPage.css'
import duck from '../../assets/Duck_Image.png'

export const ResetPasswordPage = () =>
{
    const[resetCode, setResetCode] = useState("");
    const[newPassword, setNewPassword] = useState("");
    const[errMessage, setErrorMessage] = useState("");
    const[successMessage, setSuccessMessage] = useState("");
    const[email, setEmail] = useState("");
    const [codeSent, setCodeSent] = useState(false);

    const navigate = useNavigate()

    const handleRequest = (e: FormEvent) => {
        e.preventDefault()
        setErrorMessage("");
        setSuccessMessage("");

        // send reset code to user's email if email is associated with an account
        axios.post('https://duckydollars.xyz/api/auth/resetPassword', {email: email})
        .then(() => {
            setCodeSent(true);
            setSuccessMessage(`Reset code sent to ${email}!`);
        })
        .catch(err => {
            const errMessage = err.response?.data?.error || "Server Error";
            setErrorMessage(errMessage);
        })
    }

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault()
        setErrorMessage("");

        // resets the user's password if correct reset code is entered and redirects them to the login page
        axios.post('https://duckydollars.xyz/api/auth/verifyReset', {email: email, code: resetCode, password: newPassword})
        .then(result => {
            if(result.data.id !== -1)
            {
                navigate('/login');
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
            <div className="resetDiv">
                <main className="resetMain">
                    <h2 id="resetTitle">Reset Password</h2>

                    {errMessage && (
                    <p id="resetError">Error: {errMessage}</p>
                    )}

                    {successMessage && (
                    <p id="resetSuccess">{successMessage}</p>
                    )}

                    <form className="resetForm" onSubmit={handleRequest}>
                        <input id="resetCode" onChange={(e) => setEmail(e.target.value)} type="email" placeholder="Enter Email" required disabled={codeSent}/>
                        <div className="resetButtons">
                            <button id="resetSubmit" type="submit" disabled={codeSent}>
                                {codeSent ? "Code Sent!" : "Send Code to Email"}
                            </button>
                        </div>
                    </form>

                    <br/>

                    <form className="resetForm" onSubmit={handleSubmit}>
                        <input id="resetCode" onChange={(e) => setResetCode(e.target.value)} type="text" placeholder="Enter Reset Code" required/>
                        <br/>
                        <input id="resetCode" onChange={(e) => setNewPassword(e.target.value)} type="text" placeholder="Enter New Password" required/>
                        <div className="resetButtons">
                            <button id="resetSubmit" type="submit">Reset Password</button>
                        </div>
                    </form>
                </main>
                <img id="duckImgReset" src={duck} alt="Duck Image" />
            </div>
        </>
    );
};