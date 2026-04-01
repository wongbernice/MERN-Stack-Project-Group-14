import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import { AddTransaction } from '../../components/AddTransactions/addTransactions'
import duck from '../../assets/Duck_Image.png'
import './TransactionsPage.css'

export const TransactionsPage = () =>
{
    const[isOverlay, setIsOverlay] = useState(false);
    const toggleOverlay = () => setIsOverlay(!isOverlay);

    return(
        <>
            <NavBar />
            <div className='transactionsDiv'>
                <h2 id='transactionsTitle'>Transactions</h2>

                <button id="addTransBtn" onClick={toggleOverlay}>Add Transaction</button>

                {isOverlay && (
                    <AddTransaction 
                        onClose={toggleOverlay} 
                        onSubmit={(data) => {
                            toggleOverlay();
                    }} />
                )}

                <main className='transactionsMain'>
                    {/* list of transactions */}
                </main>
            </div>
            <img id="duckImgTrans" src={duck} alt="Duck Image" />
        </>
    );
};