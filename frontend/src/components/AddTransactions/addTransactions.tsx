import './addTransactionsPage.css'
import { useState, useEffect, type FormEvent} from 'react';

//defining items need to close the popup/overlay
interface OverlayItems {
    onClose: () => void;
    onSubmit: (data: any) => void;
}

//defining category 
interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
    userId: string;
}

export const AddTransaction = ({onClose, onSubmit}: OverlayItems) => 
{
    const [categories, setCategories] = useState<Category[]>([]);
    const [catId, setCatId] = useState("");
    const [amount, setAmount] = useState("");
    const [date, setDate] = useState("");
    const [note, setNote] = useState("");

    //get categories for user from db
    useEffect(() => {
        const getCategories = async () => {
            const userId = localStorage.getItem('_id');
            if(!userId)
                return;

            try {
                const response = await fetch(`http://67.205.159.14:5000/api/categories?userId=${userId}`);
                const data = await response.json();

                if(data.categories)
                {
                    setCategories(data.categories);
                }
            } catch (error){
                console.log("error getting categories: ", error);
            }
        };
        getCategories();
    }, []);

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault();
        const transactionInfo = {
            userId: localStorage.getItem('_id'),
            categoryId: catId,
            amount: parseFloat(amount),
            date: date,
            note: note
        };
        onSubmit(transactionInfo);
        console.log(transactionInfo); //will remove
    }

    return(
        <>
            <div className="overlay" onClick={onClose}>
                <div className='formCard' onClick={(e) => e.stopPropagation()}>
                    <button id="closeForm" onClick={onClose}>X</button>
                    <h3 id='addTitle'>Add Transaction</h3>
                    <form className='newTransaction' onSubmit={handleSubmit}>
                        <input id='transDate' type='date' placeholder='Date' required/>
                        <br/>
                        <select id='transCategory' value={catId} onChange={(e) => setCatId(e.target.value)}required>
                            <option value="">Select Category</option>
                            {categories.map((cat) => (
                            <option key={cat._id} value={cat._id}>
                                {cat.name}
                            </option>
                        ))}
                        </select>
                        <br/>
                        <input id='transAmount' type='number' placeholder='Amount' required/>
                        <br/>
                        <textarea id='transNote' placeholder='Notes' rows={4} required/>
                        <br/>
                        <button id='newTransSubmit' type='submit'>Add</button>
                    </form>
                </div>
            </div>
        </>
    )
}