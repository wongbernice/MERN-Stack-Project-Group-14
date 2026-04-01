import axios from 'axios';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import PopupForm from '../../components/AddCategory/addBudgetPopup';

// 1 Button - Add Budget Category
    // Brings up pop up for the user to add a category name & budget amount
    // When save is hit, 
        // Budget Amount must be a float number
        // Category Name must be a string
        // Cannot save if either field is empty or inputs are invalid

// Dynamic table that adds a row when a new category is added

export const BudgetPage = () =>
{
    const [showPopup, setShowPopup] = useState(false);

    return(
        <>
            <NavBar />
            <h1>Monthly Budget</h1>
            <button id="budgetCat" onClick={() => setShowPopup(true)}>Add Budget Category</button>

            {showPopup && (
                <PopupForm close={() => setShowPopup(false)} />
            )}

            <table id="budgetTable">

            </table>
        </>
    );
};

export default BudgetPage;