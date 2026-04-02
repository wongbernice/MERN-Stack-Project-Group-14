import './Budget.css'

import axios from 'axios';
import { useState, useEffect } from 'react';
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

type Category = {
  id: number;
  name: string;
  budgetLimit: number;
};

export const BudgetPage = () =>
{
    const [showPopup, setShowPopup] = useState(false);
    const [categories, setCategories] = useState<Category[]>([]);

    const handleSave = async (name: string, budgetLimit: number) =>{
        try{
            const userId = localStorage.getItem("_id");

            const response = await axios.post("http://67.205.159.14:5000/api/categories", {
                userId,
                name,
                budgetLimit,
            })

            setCategories((prev) => [...prev, { id: response.data.id, name, budgetLimit }]);
            setShowPopup(false);
        }
        catch (error) {
            console.error("Failed to save category:", error);
        }
    }

    useEffect(() => {
        const fetchCategories = async () => {
            try {
                const userId = localStorage.getItem("_id");
                const response = await axios.get(`http://67.205.159.14:5000/api/categories/${userId}`);
                setCategories(response.data.categories);
            } catch (error) {
                console.error("Failed to fetch categories:", error);
            }
        };

        fetchCategories();
    }, []);

    return(
        <>
            <NavBar />
            <div className="budgetDiv">
                <h1 id="budgetTitle">Monthly Budget</h1>

                <div className="budgetTableContainer">
                    <div className="tableHeader">
                        <h2>Budget Categories</h2>
                        <p>|</p>
                        <button id="budgetCat" onClick={() => setShowPopup(true)}>Add Budget Category</button>
                    </div>

                    {showPopup && (
                        <PopupForm close={() => setShowPopup(false)} onSave={handleSave} />
                    )}

                    <table id="budgetTable">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Budget Limit</th>
                                <th>Amount Spent</th>
                                <th>Amount Left</th>
                            </tr>
                            </thead>
                            <tbody>
                            {categories.map((cat) => (
                                <tr key={cat.id}>
                                <td>{cat.name}</td>
                                <td>${cat.budgetLimit}</td>
                                </tr>
                            ))}
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td>Total:</td>
                                </tr>
                            </tfoot>
                    </table>
                </div>
            </div>
        </>
    );
};

export default BudgetPage;