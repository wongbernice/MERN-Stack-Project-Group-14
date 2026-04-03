import './BudgetPopup.css'
import { useState } from "react";
import type { ChangeEvent, FormEvent } from "react";

type PopupFormProps = {
  close: () => void;
  onSave: (name: string, budgetLimit: number) => void;
  initialName?: string;
  initialAmount?: number | "";
};

const PopupForm = ({ close, onSave, initialName = "", initialAmount = "" }: PopupFormProps) => {
    const [category, setCategory] = useState<string>(initialName);
    const [amount, setAmount] = useState<number | "">(initialAmount);
    const[errMessage, setErrorMessage] = useState("");

    const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault();

        if(!category|| amount === "")
        {
            setErrorMessage("All fields are required!");
            return;
        }
        
        if(amount <= 0){
            setErrorMessage("Budget Amount must be greater than zero!");
            return;
        }

        onSave(category, amount);
    };

    return(
        <>
            <div className = "popup">

                <form id="budgetForm" onSubmit={handleSubmit}>
                    <button id="closeBtn" type="button" onClick={close}>X</button>
                    <h2>Add Budget Category</h2>

                    {errMessage && <p style={{ color: "red" }}>{errMessage}</p>}

                    <input 
                        type="text" 
                        value={category} 
                        onChange={(e: ChangeEvent<HTMLInputElement>) => {
                            setCategory(e.target.value);
                            setErrorMessage("");
                        }}
                        placeholder="Category name">
                    </input>

                    <input 
                        type="number" 
                        value={amount} 
                        min={0}
                        onChange={(e: ChangeEvent<HTMLInputElement>) => {
                            const val = e.target.value;
                            setAmount(val === "" ? "" : Number(val));
                            setErrorMessage("");
                        }}
                            placeholder="Budget amount">
                    </input>

                    <button id="saveBtn" type="submit">Save</button>
                </form>
            </div>
        </>
    )

};
export default PopupForm;