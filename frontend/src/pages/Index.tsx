import { useNavigate } from 'react-router-dom'

export const Index = () => 
{
    const navigate = useNavigate();
    return(
        <>
            <h1>Index</h1>
            <div className="IndexButtons">
                <button id="newUser" type="button" onClick={() => navigate('/signUp')}>Sign Up</button>
                <button id="existingUser" type="button" onClick={() => navigate('/login')}>Login</button>
            </div>
        </>
    );
};