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

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault()
        setErrorMessage("");

        const email = localStorage.getItem("email");

        // allows user to verify account if correct verification code is entered
        axios.post('https://duckydollars.xyz/api/auth/verify', {email: email, code: verificationCode})
        .then(result => {
            if(result.data.id !== -1)
            {
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
                    <p id="verifyError">Error: {errMessage}</p>
                    )}

                    <form className="verifyForm" onSubmit={handleSubmit}>
                        <input id="verifyCode" onChange={handleCodeChange} type="text" placeholder="Enter Verification Code" required/>
                        <br/>
                        <div className="verifyButtons">
                            <button id="verifySubmit" type="submit">Verify Email</button>
                        </div>
                    </form>
                </main>
                <img id="duckImgVerify" src={duck} alt="Duck Image" />
            </div>
        </>
    );
};