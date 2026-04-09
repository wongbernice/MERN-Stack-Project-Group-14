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

    const token = localStorage.getItem('token');
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

    useEffect(() => {
        const fetchData = async () => {
            try {
                const catRes = await axios.get(`http://67.205.159.14:5000/api/categories`);
                setCategories(catRes.data.categories);

                const transRes = await axios.get(`http://67.205.159.14:5000/api/transactions`);
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
                <h1 id="dashTitle">Ducky Dashboard</h1>

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

                <div className="recentTransactions">
                    <h2>Recent Transactions</h2>

                    <table id="recentTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Category</th>
                                <th>Note</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            {[...transactions]
                                .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
                                .slice(0, 5)
                                .map((t) => {
                                    const category = categories.find(cat => cat._id === t.categoryId);
                                    return (
                                        <tr key={t._id}>
                                            <td>{new Date(t.date).toLocaleDateString()}</td>
                                            <td>{category ? category.name : 'Unknown'}</td>
                                            <td>{t.note}</td>
                                            <td>${t.amount.toFixed(2)}</td>
                                        </tr>
                                    );
                                })}
                        </tbody>
                    </table>
                </div>
            </div>
        </>
    );
};