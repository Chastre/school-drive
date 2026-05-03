<%-- 
    Document   : modal_confirmacao
    Created on : 16/12/2025, 15:02:04
    Author     : pmnch
--%>

<!-- Modal de Confirmação Personalizada -->
<style>
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        z-index: 9999;
        justify-content: center;
        align-items: center;
        animation: fadeIn 0.3s;
    }

    .modal-overlay.active {
        display: flex;
    }

    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }

    @keyframes slideDown {
        from { 
            transform: translateY(-50px);
            opacity: 0;
        }
        to { 
            transform: translateY(0);
            opacity: 1;
        }
    }

    .modal-box {
        background: white;
        border-radius: 15px;
        padding: 30px;
        max-width: 450px;
        width: 90%;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        animation: slideDown 0.3s;
    }

    .modal-icon {
        font-size: 4rem;
        text-align: center;
        margin-bottom: 20px;
    }

    .modal-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: #333;
        text-align: center;
        margin-bottom: 15px;
    }

    .modal-message {
        font-size: 1rem;
        color: #666;
        text-align: center;
        margin-bottom: 30px;
        line-height: 1.5;
    }

    .modal-buttons {
        display: flex;
        gap: 15px;
        justify-content: center;
    }

    .modal-btn {
        padding: 12px 30px;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
    }

    .modal-btn-cancel {
        background: #6c757d;
        color: white;
    }

    .modal-btn-cancel:hover {
        background: #5a6268;
        transform: translateY(-2px);
    }

    .modal-btn-confirm {
        background: #dc3545;
        color: white;
    }

    .modal-btn-confirm:hover {
        background: #c82333;
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(220, 53, 69, 0.4);
    }
</style>

<div id="modalConfirmacao" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-icon">??</div>
        <h2 class="modal-title">Confirmar Eliminação</h2>
        <p class="modal-message" id="modalMessage">Tens a certeza que queres eliminar este item?</p>
        <div class="modal-buttons">
            <button class="modal-btn modal-btn-cancel" onclick="fecharModal()">? Cancelar</button>
            <button class="modal-btn modal-btn-confirm" onclick="confirmarEliminacao()">?? Eliminar</button>
        </div>
    </div>
</div>

<script>
    let urlEliminacao = '';

    function mostrarModal(url, mensagem) {
        urlEliminacao = url;
        document.getElementById('modalMessage').textContent = mensagem;
        document.getElementById('modalConfirmacao').classList.add('active');
    }

    function fecharModal() {
        document.getElementById('modalConfirmacao').classList.remove('active');
    }

    function confirmarEliminacao() {
        window.location.href = urlEliminacao;
    }

    // Fechar modal ao clicar fora
    document.getElementById('modalConfirmacao').addEventListener('click', function(e) {
        if (e.target === this) {
            fecharModal();
        }
    });

    // Fechar modal com ESC
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            fecharModal();
        }
    });
</script>
