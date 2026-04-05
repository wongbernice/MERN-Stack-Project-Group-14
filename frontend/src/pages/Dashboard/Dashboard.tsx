import './DashboardStyle.css'

import axios from 'axios';
import { useState,useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import { BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import StatCards from '../../components/Dashboard/StatCards';
import CategoryBarChart from '../../components/Dashboard/CategoryBarChart';
import ExpensesPieChart from '../../components/Dashboard/ExpensesPieChart';
import BudgetPieChart from '../../components/Dashboard/BudgetPieChart';

/*
    Reset button to be added on Dashboard (or somewhere else currently TBD)
        When the user clicks it they will get an are you sure message and then immediately prompted, Welcome to Ducky Dollars!
        what month is the budget for?
        All of the data in the database is reset, and then the month is replaced all over the app in text so that they know which month
        they are currently working on

    Dashboard will display
        1. Stat Cards
            - These include:
            Total Spent
            Total Budget allocated
            How much money they have remaining from their budget
            Number of Transactions

        2. Monthly Spending Chart
            - Shows the user the amount they spent, and how much budget they set per category in a bar graph 
            (Could be from left to right rather than up and down to avoid crowding)

        3. Expenses Pie Chart
            - Shows the user the percent the percent that's been spent of the budget per category

        4. Amount Left vs. Amount Spent Pie Chart
        
        All are supposed to dynamically change as categories, budgets, and transactions are added to the system
*/

interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
}

interface Transaction {
    _id: string;
    date: string;
    categoryId: string;
    note: string;
    amount: number;
}

export const DashboardPage = () =>
{
    const [categories, setCategories] = useState<Category[]>([]);
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchData = async () => {
            try {
                const userId = localStorage.getItem("_id");
                const catRes = await axios.get(`http://67.205.159.14:5000/api/categories`, {
                    params: { userId }
                });
                setCategories(catRes.data.categories);

                const transRes = await axios.get(`http://67.205.159.14:5000/api/transactions?userId=${userId}`);
                setTransactions(transRes.data.transactions);
            } catch (error) {
                console.error("Failed to fetch dashboard data:", error);
            }
        };
        fetchData();
    }, []);

    const totalBudget = categories.reduce((sum, cat) => sum + cat.budgetLimit, 0);
    const totalSpent = categories.reduce((sum, cat) => sum + cat.budgetSpent, 0);
    const remaining = totalBudget - totalSpent;

    return(
        <>
            <NavBar />
            <div className="dashDiv">
                <h1 id="dashTitle">Username's Ducky Dashboard</h1>

                <StatCards
                    totalSpent={totalSpent}
                    totalBudget={totalBudget}
                    remaining={remaining}
                    numTransactions={transactions.length}
                />

                <CategoryBarChart categories={categories} />

                <div className="pieChartsRow">
                    <ExpensesPieChart categories={categories} />
                    <BudgetPieChart totalSpent={totalSpent} remaining={remaining} />
                </div>

                <div className="dashFooter">
                    <button id="editBudgetBtn" onClick={() => navigate('/budget')}>Edit Budget</button>
                </div>
            </div>
        </>
    );
};