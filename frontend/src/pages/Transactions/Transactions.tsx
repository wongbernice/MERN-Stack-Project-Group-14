import axios from 'axios';
import { useState, type ChangeEvent, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import { AddTransaction } from '../../components/AddTransactions/addTransactions'
import duck from '../../assets/Duck_Image.png'

export const TransactionsPage = () =>
{
    const[isOverlay, setIsOverlay] = useState(false);
    const toggleOverlay = () => setIsOverlay(!isOverlay);

    return(
        <>
            <NavBar />
            <h2>Transactions</h2>

            <button id="addTransBtn" onClick={toggleOverlay}>Add Transaction</button>

            {isOverlay && (
                <AddTransaction 
                    onClose={toggleOverlay} 
                    onSubmit={(data) => {
                        toggleOverlay();
                }} />
            )}

            {/* list of transactions */}
        </>
    );
};