import './Budget.css'

import axios from 'axios';
import { useState, useEffect } from 'react';
import { NavBar } from '../../components/NavBar/NavBar'
import PopupForm from '../../components/AddCategory/addBudgetPopup';
import deleteIcon from '../../assets/deleteIcon.png';
import editIcon from '../../assets/editIcon.png';

// 1 Button - Add Budget Category
    // Brings up pop up for the user to add a category name & budget amount
    // When save is hit, 
        // Budget Amount must be a float number
        // Category Name must be a string
        // Cannot save if either field is empty or inputs are invalid

// Dynamic table that adds a row when a new category is added

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

    const handleSave = async (name: string, budgetLimit: number) =>{
        try{
            const response = await axios.post("http://67.205.159.14:5000/api/categories", {
                name,
                budgetLimit,
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
            await axios.put(`http://67.205.159.14:5000/api/categories/${editingCategory._id}`, {
                name,
                budgetLimit,
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
        try {
            await axios.delete(`http://67.205.159.14:5000/api/categories/${id}`);
            setCategories((prev) => prev.filter((cat) => cat._id !== id));
        } catch (error) {
            console.error("Failed to delete category:", error);
        }
    };

    useEffect(() => {
        const fetchCategories = async () => {
            try {
                const response = await axios.get(`http://67.205.159.14:5000/api/categories`);
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
                        </div>
                        <button 
                            id={editMode ? "doneModeBtn" : "editModeBtn"} onClick={() => setEditMode(!editMode)}>
                            {editMode ? "Done" : "Edit ★"}
                        </button>
                    </div>

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
            </div>
        </>
    );
};

export default BudgetPage;