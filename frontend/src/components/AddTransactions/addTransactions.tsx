//defining items need to close the popup/overlay
interface OverlayItems {
    onClose: () => void;
    onSubmit: (data: any) => void;
}

export const AddTransaction = ({onClose, onSubmit}: OverlayItems) => 
{
    return(
        <>
            <div className="overlay" onClick={onClose}>
                
            </div>
        </>
    )
}