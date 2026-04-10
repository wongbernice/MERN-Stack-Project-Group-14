import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import './VerifyPage.css'
import duck from '../../assets/Duck_Image.webp'

export const VerifyPage = () =>
{
    const[verificationCode, setVerificationCode] = useState("");
    const[errMessage, setErrorMessage] = useState("");
    const navigate = useNavigate()

    function handleCodeChange(data: ChangeEvent<HTMLInputElement>)
    {
        setVerificationCode(data.target.value);
    }

    const handleResend = () => {
        setErrorMessage("");

        const email = localStorage.getItem("email");

        // allows user to resend verification code
        axios.post('https://duckydollars.xyz/api/auth/resendverification', {email: email})
        .then(result => {
            setErrorMessage("Verification code resent!");
        
        })
        .catch(err => {
            const errMessage = err.response?.data?.error || "Server Error";
            setErrorMessage(errMessage);
        })
    }

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault()
        setErrorMessage("");

        const email = localStorage.getItem("email");

        // allows user to verify account if correct verification code is entered
        axios.post('https://duckydollars.xyz/api/auth/verify', {email: email, code: verificationCode})
        .then(result => {
            if(result.data.id !== -1)
            {
                // save token so user can stay logged in
                if (result.data.token) {
                    localStorage.setItem('token', result.data.token);
                }

                localStorage.setItem('isVerified', 'true');
                navigate('/dashboard');
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
            <div className="verifyDiv">
                <main className="verifyMain">
                    <h2 id="verifyTitle">Verify Email</h2>

                    {errMessage && (
                        <p id="verifyError" role="alert" aria-live='assertive'>Error: {errMessage}</p>
                    )}

                    <form className="verifyForm" onSubmit={handleSubmit}>
                        <label htmlFor='verifyCode' id='verifyCodeLabel'></label>
                        <input id="verifyCode" onChange={handleCodeChange} type="text" placeholder="Enter Verification Code" required/>
                        <br/>
                        <div className="verifyButtons">
                            <button id="verifySubmit" type="submit">Verify Email</button>
                            <button id="resendVerification" type="button" onClick={handleResend}>Resend Verification Code</button>
                        </div>
                    </form>
                </main>
                <img id="duckImgVerify" src={duck} width="120" height="120" loading="eager" fetchPriority='low' alt="Duck Image" />
            </div>
        </>
    );
};