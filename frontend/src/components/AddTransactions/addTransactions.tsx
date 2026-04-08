import './addTransactionsPage.css'
import { useState, useEffect, type FormEvent} from 'react';

//defining items need to close the popup/overlay
interface OverlayItems {
    onClose: () => void;
    onSubmit: (data: any) => void;
    initialData?: Transaction | null;
}

//defining category 
interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
    userId: string;
}

//defining transaction
interface Transaction {
    _id: string;
    date: string;
    categoryId:string;
    note:string;
    amount: number;
}

export const AddTransaction = ({onClose, onSubmit, initialData}: OverlayItems) => 
{
    const [categories, setCategories] = useState<Category[]>([]);
    const [catId, setCatId] = useState(initialData?.categoryId || "");
    const [amount, setAmount] = useState(initialData?.amount?.toString() || "");
    const [date, setDate] = useState(initialData?.date || "");
    const [note, setNote] = useState(initialData?.note || "");


    //get categories for user from db
    useEffect(() => {
        const getCategories = async () => {
            const userId = localStorage.getItem('_id');
            const token = localStorage.getItem('token');
            if (!userId || !token) return;

            try {
                const response = await fetch(`http://67.205.159.14:5000/api/categories?userId=${userId}`, {
                    headers: {
                        Authorization: `Bearer ${token}`
                    }
                });
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

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        const transactionInfo = {
            userId: localStorage.getItem('_id'),
            categoryId: catId,
            amount: parseFloat(amount),
            date: date,
            note: note
        };
        onSubmit(transactionInfo);
    }

    const unqiueCats = categories.filter((value, index, self) =>
        index === self.findIndex((t) => t.name === value.name)
    );

    return(
        <>
            <div className="overlay" onClick={onClose}>
                <div className='formCard' onClick={(e) => e.stopPropagation()}>
                    <button id="closeForm" onClick={onClose}>X</button>
                    <h3 id='addTitle'>{initialData ? "Edit Transaction" : "Add Transaction"}</h3>
                    <form className='newTransaction' onSubmit={handleSubmit}>
                        <input id='transDate' type='date' placeholder='Date' value={date} onChange={(e) => setDate(e.target.value)} required/>
                        <br/>
                        <select id='transCategory' value={catId} onChange={(e) => setCatId(e.target.value)}required>
                            <option value="">Select Category</option>
                            {unqiueCats.map((cat) => (
                            <option key={cat._id} value={cat._id}>
                                {cat.name}
                            </option>
                        ))}
                        </select>
                        <br/>
                        <input id='transAmount' type='number' placeholder='Amount' value={amount} onChange={(e) => setAmount(e.target.value)}required/>
                        <br/>
                        <textarea id='transNote' placeholder='Notes' rows={4} value={note} onChange={(e) => setNote(e.target.value)} required/>
                        <br/>
                        <button id='newTransSubmit' type='submit'>{initialData ? "Update" : "Add"}</button>
                    </form>
                </div>
            </div>
        </>
    )
}