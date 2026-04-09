import './Budget.css'

import axios from 'axios';
import { useState, useEffect } from 'react';
import { NavBar } from '../../components/NavBar/NavBar'
import PopupForm from '../../components/AddCategory/addBudgetPopup';
import deleteIcon from '../../assets/deleteIcon.png';
import editIcon from '../../assets/editIcon.png';
import duck from '../../assets/Duck_Image.png'

type Category = {
  _id: string;
  name: string;
  budgetLimit: number;
  budgetSpent: number;
};

export const BudgetPage = () =>
{
    const [showPopup, setShowPopup] = useState(false);
    const [categories, setCategories] = useState<Category[]>([]);
    const [editingCategory, setEditingCategory] = useState<Category | null>(null);
    const [editMode, setEditMode] = useState(false);
    const [showResetConfirm, setShowResetConfirm] = useState(false);

    const userId = localStorage.getItem('_id');

    const handleSave = async (name: string, budgetLimit: number) =>{
        try{
            const token = localStorage.getItem('token');
            console.log("token:", token);
            console.log("userId:", userId);

            const response = await axios.post("https://duckydollars.xyz/api/categories", {
                name,
                budgetLimit,
                userId
            },
            {
                headers: {
                    Authorization: `Bearer ${token}`
                }
            })
            setCategories((prev) => [...prev, { _id: response.data.id, name, budgetLimit, budgetSpent: 0}]);
            setShowPopup(false);
        }
        catch (error) {
            console.error("Failed to save category:", error);
        }
    }

    const handleEdit = async (name: string, budgetLimit: number) => {
        if (!editingCategory) return;
        try {
            const token = localStorage.getItem('token');

            await axios.put(`https://duckydollars.xyz/api/categories/${editingCategory._id}`, {
                name,
                budgetLimit,
                userId
            },
            {
                headers: {
                    Authorization: `Bearer ${token}`
                }
            });
            setCategories((prev) =>
                prev.map((cat) =>
                    cat._id === editingCategory._id ? { ...cat, name, budgetLimit } : cat
                )
            );
            setEditingCategory(null);
        } catch (error) {
            console.error("Failed to update category:", error);
        }
    };

    const handleDelete = async (id: string) => {
        const confirmed = window.confirm("Are you sure you want to delete this category? This will also delete all transactions in this category.");
        if (!confirmed) return;

        try {
            const token = localStorage.getItem('token');

            // First delete the category's transactions and reset it
            await axios.put(`https://duckydollars.xyz/api/categories/${id}/reset`, {}, {
                headers: { Authorization: `Bearer ${token}` }
            });

            // Then delete the category itself
            await axios.delete(`https://duckydollars.xyz/api/categories/${id}?userId=${userId}`, {
                headers: { Authorization: `Bearer ${token}` }
            });

            setCategories((prev) => prev.filter((cat) => cat._id !== id));
        } catch (error) {
            console.error("Failed to delete category:", error);
        }
    };

    const handleResetAll = async () => {
        try {
            const token = localStorage.getItem('token');

            for (const cat of categories) {
                await axios.put(`https://duckydollars.xyz/api/categories/${cat._id}/reset`, {}, {
                    headers: { Authorization: `Bearer ${token}` }
                });

                await axios.delete(`https://duckydollars.xyz/api/categories/${cat._id}?userId=${userId}`, {
                    headers: { Authorization: `Bearer ${token}` }
                });
            }

            setCategories([]);
            setShowResetConfirm(false);
        } catch (error) {
            console.error("Failed to reset categories:", error);
        }
    };

    useEffect(() => {
        const fetchCategories = async () => {
            try {
                const token = localStorage.getItem('token');
                const userId = localStorage.getItem('_id');
                if (!token) return;

                const response = await axios.get(`https://duckydollars.xyz/api/categories?userId=${userId}`,
                    {
                        headers: {
                            Authorization: `Bearer ${token}`
                        }
                    }
                );
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
                        <div className="tableHeaderLeft">
                            <h2>Budget Categories</h2>
                            <p>|</p>
                            <button id="budgetCat" onClick={() => setShowPopup(true)}>Add Budget Category</button>
                            <p>|</p>
                            <button id="resetAllBtn" onClick={() => setShowResetConfirm(true)}>Reset Month</button>
                        </div>
                        <button 
                            id={editMode ? "doneModeBtn" : "editModeBtn"} onClick={() => setEditMode(!editMode)}>
                            {editMode ? "Done" : "Edit ★"}
                        </button>
                    </div>

                    {showResetConfirm && (
                        <div className="confirmOverlay">
                            <div className="confirmBox">
                                <p id="AYS">Are you sure?</p>
                                <p>This will delete all transaction history, reset your spending to $0, and reset your budget categories.</p>
                                <div className="confirmButtons">
                                    <button className="confirmBtn confirm" onClick={handleResetAll}>Yes, Reset</button>
                                    <button className="confirmBtn cancel" onClick={() => setShowResetConfirm(false)}>Cancel</button>
                                </div>
                            </div>
                        </div>
                    )}

                    {showPopup && (
                        <PopupForm close={() => setShowPopup(false)} onSave={handleSave} />
                    )}

                    {editingCategory && (
                    <PopupForm
                        close={() => setEditingCategory(null)}
                        onSave={handleEdit}
                        initialName={editingCategory.name}
                        initialAmount={editingCategory.budgetLimit}
                    />
                    )}

                    <table id="budgetTable">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Budget Limit</th>
                                <th>Amount Spent</th>
                                <th>Amount Left</th>
                                {editMode && <th></th>}
                            </tr>
                            </thead>
                            <tbody>
                            {categories.map((cat) => (
                                <tr key={cat._id}>
                                    <td>{cat.name}</td>
                                    <td>${cat.budgetLimit.toFixed(2)}</td>
                                    <td>${cat.budgetSpent.toFixed(2)}</td>
                                    <td>${(cat.budgetLimit - cat.budgetSpent).toFixed(2)}</td>
                                    {editMode && (
                                        <td>
                                            <button className="editBtnBudg" onClick={() => setEditingCategory(cat)}>
                                                <img id="editIcon" src={editIcon} alt="edit" />
                                            </button>
                                            <button className="deleteBtnBudg" onClick={() => handleDelete(cat._id)}>
                                                <img id="deleteIcon" src={deleteIcon} alt="delete" />
                                            </button>
                                        </td>
                                    )}
                                </tr>
                            ))}
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td>Total:</td>
                                    <td>${categories.reduce((sum, cat) => sum + cat.budgetLimit, 0).toFixed(2)}</td>
                                    <td>${categories.reduce((sum, cat) => sum + cat.budgetSpent, 0).toFixed(2)}</td>
                                    <td>${categories.reduce((sum, cat) => sum + (cat.budgetLimit - cat.budgetSpent), 0).toFixed(2)}</td>
                                </tr>
                            </tfoot>
                    </table>
                </div>
                <img id="duckImgBudget" src={duck} alt="Duck Image" />
            </div>
        </>
    );
};

export default BudgetPage;