import { useState } from "react";
import type { ChangeEvent, FormEvent } from "react";

type PopupFormProps = {
  close: () => void;
};

const PopupForm = ({ close }: PopupFormProps) => {
    const [category, setCategory] = useState<string>("");
    const [amount, setAmount] = useState<number | "">("");
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

    };

    return(
        <>
            <h2>Add Budget Category</h2>

            {errMessage && <p style={{ color: "red" }}>{errMessage}</p>}

            <form onSubmit={handleSubmit}>
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

                <button type="submit">Save</button>
                <button type="button" onClick={close}>Cancel</button>
            </form>
        </>
    )

};
export default PopupForm;