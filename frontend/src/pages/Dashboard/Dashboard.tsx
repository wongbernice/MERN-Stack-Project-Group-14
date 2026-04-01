import axios from 'axios';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'

export const DashboardPage = () =>
{
    return(
        <>
            <NavBar />
            <h1>Dashboard</h1>
        </>
    );
};