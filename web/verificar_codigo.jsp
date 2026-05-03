<%-- 
    Document   : verificar_codigo
    Created on : 07/01/2026, 09:49:41
    Author     : pmnch
--%>

<%-- 
    Document   : verificar_codigo
    Created on : 07/01/2026, 09:49:41
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verificar se tem dados na sessão
    String emailVerificacao = (String) session.getAttribute("email_verificacao");
    String nomeVerificacao = (String) session.getAttribute("nome_verificacao");
    String codigoCorreto = (String) session.getAttribute("codigo_verificacao");
    
    if (emailVerificacao == null || codigoCorreto == null) {
        response.sendRedirect("registar_aluno.jsp");
        return;
    }
    
    String mensagemErro = null;
    
    // Processar verificação do código
    if (request.getMethod().equals("POST")) {
        String codigoInserido = request.getParameter("codigo");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConexaoBD.getConnection();
            
            // Buscar dados da inscrição temporária
            String sqlTemp = "SELECT * FROM inscricao_temp WHERE email = ? AND codigo = ? AND verificado = FALSE ORDER BY dataCriacao DESC LIMIT 1";
            pstmt = conn.prepareStatement(sqlTemp);
            pstmt.setString(1, emailVerificacao);
            pstmt.setString(2, codigoInserido);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // Código correto! Criar aluno
                String nome = rs.getString("nome");
                String email = rs.getString("email");
                String telemovel = rs.getString("telemovel");
                String morada = rs.getString("morada");
                Date dataNascimento = rs.getDate("dataNascimento");
                String categoria = rs.getString("categoria");
                String tipoPagamento = rs.getString("tipoPagamento");
                double valorTotal = rs.getDouble("valorTotal");
                String username = rs.getString("username");
                String password = rs.getString("password");
                
                rs.close();
                pstmt.close();
                
                // Inserir aluno (COM idInstrutor para poder agendar aulas!)
                String sqlAluno = "INSERT INTO aluno (nome, email, emailVerificado, telemovel, morada, dataNascimento, categoria, dataInscricao, tipoPagamento, valorTotal, idInstrutor) " +
                                 "VALUES (?, ?, TRUE, ?, ?, ?, ?, CURDATE(), ?, ?, 1)";
                pstmt = conn.prepareStatement(sqlAluno, Statement.RETURN_GENERATED_KEYS);
                pstmt.setString(1, nome);
                pstmt.setString(2, email);
                pstmt.setString(3, telemovel);
                pstmt.setString(4, morada);
                pstmt.setDate(5, dataNascimento);
                pstmt.setString(6, categoria);
                pstmt.setString(7, tipoPagamento);
                pstmt.setDouble(8, valorTotal);
                
                pstmt.executeUpdate();
                
                // Obter ID do aluno
                rs = pstmt.getGeneratedKeys();
                int idAluno = 0;
                if (rs.next()) {
                    idAluno = rs.getInt(1);
                }
                rs.close();
                pstmt.close();
                
                // Criar utilizador INATIVO
                String sqlUser = "INSERT INTO t_utilizador (tipo, username, password, ativo, idAluno) VALUES ('Aluno', ?, ?, 0, ?)";
                pstmt = conn.prepareStatement(sqlUser);
                pstmt.setString(1, username);
                pstmt.setString(2, password);
                pstmt.setInt(3, idAluno);
                pstmt.executeUpdate();
                pstmt.close();
                
                // Marcar inscrição como verificada
                String sqlUpdate = "UPDATE inscricao_temp SET verificado = TRUE WHERE email = ? AND codigo = ?";
                pstmt = conn.prepareStatement(sqlUpdate);
                pstmt.setString(1, email);
                pstmt.setString(2, codigoInserido);
                pstmt.executeUpdate();
                
                // Limpar sessão
                session.removeAttribute("email_verificacao");
                session.removeAttribute("nome_verificacao");
                session.removeAttribute("codigo_verificacao");
                
                // Redirecionar para sucesso
                response.sendRedirect("inscricao_sucesso.jsp");
                return;
                
            } else {
                mensagemErro = "Código inválido! Verifique e tente novamente.";
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            mensagemErro = "Erro ao verificar código: " + e.getMessage();
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Verificar Email - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    
    <!-- EmailJS SDK -->
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/email.min.js"></script>
    <script type="text/javascript">
        (function(){
            emailjs.init("mUFdf5WBMBA1dGgps"); // Public Key
        })();
    </script>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Work Sans', sans-serif;
            min-height: 100vh;
            background: linear-gradient(135deg, #2C5F7C 0%, #800020 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .verify-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 50px 40px;
            max-width: 500px;
            width: 100%;
            text-align: center;
            animation: slideUp 0.5s ease;
        }
        
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .icon {
            font-size: 5rem;
            color: #FFC107;
            margin-bottom: 20px;
        }
        
        h1 {
            color: #2C5F7C;
            font-size: 2rem;
            margin-bottom: 15px;
        }
        
        .email-info {
            background: rgba(255, 193, 7, 0.1);
            border: 2px solid #FFC107;
            padding: 15px;
            border-radius: 10px;
            margin: 25px 0;
        }
        
        .email-info strong {
            color: #2C5F7C;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 2px solid #dc3545;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .code-input {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin: 30px 0;
        }
        
        .code-input input {
            width: 50px;
            height: 60px;
            text-align: center;
            font-size: 2rem;
            font-weight: 700;
            border: 2px solid #ddd;
            border-radius: 10px;
            transition: all 0.3s;
        }
        
        .code-input input:focus {
            outline: none;
            border-color: #FFC107;
            box-shadow: 0 0 0 4px rgba(255, 193, 7, 0.2);
        }
        
        .btn {
            padding: 15px 40px;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s;
            margin: 10px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #FFC107 0%, #FFB300 100%);
            color: #333;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 193, 7, 0.4);
        }
        
        .btn-secondary {
            background: #8B6F47;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #a58a5f;
        }
        
        .resend-link {
            color: #2C5F7C;
            text-decoration: underline;
            cursor: pointer;
            margin-top: 20px;
            display: inline-block;
        }
        
        .resend-link:hover {
            color: #FFC107;
        }
        
        #loading {
            display: none;
            margin-top: 20px;
        }
        
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #FFC107;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        @media (max-width: 768px) {
            .verify-card {
                padding: 30px 20px;
            }
            
            h1 {
                font-size: 1.5rem;
            }
            
            .code-input input {
                width: 40px;
                height: 50px;
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="verify-card">
        <div class="icon">
            <i class="fa fa-envelope-open"></i>
        </div>
        
        <h1>Verificar Email</h1>
        <p style="color: #666; margin-bottom: 20px;">
            Enviámos um código de 6 dígitos para o seu email
        </p>
        
        <div class="email-info">
            <strong><%= emailVerificacao %></strong>
        </div>
        
        <% if (mensagemErro != null) { %>
            <div class="alert-error">
                <i class="fa fa-exclamation-triangle"></i>
                <%= mensagemErro %>
            </div>
        <% } %>
        
        <form method="POST" action="verificar_codigo.jsp" id="formCodigo">
            <div class="code-input">
                <input type="text" maxlength="1" name="d1" id="d1" required autocomplete="off">
                <input type="text" maxlength="1" name="d2" id="d2" required autocomplete="off">
                <input type="text" maxlength="1" name="d3" id="d3" required autocomplete="off">
                <input type="text" maxlength="1" name="d4" id="d4" required autocomplete="off">
                <input type="text" maxlength="1" name="d5" id="d5" required autocomplete="off">
                <input type="text" maxlength="1" name="d6" id="d6" required autocomplete="off">
            </div>
            
            <input type="hidden" name="codigo" id="codigoFinal">
            
            <button type="submit" class="btn btn-primary">
                <i class="fa fa-check"></i>
                Verificar Código
            </button>
            
            <a href="registar_aluno.jsp" class="btn btn-secondary">
                <i class="fa fa-arrow-left"></i>
                Voltar
            </a>
        </form>
        
        <div id="loading" style="display: none;">
            <div class="spinner"></div>
            <p>A enviar email...</p>
        </div>
        
        <a class="resend-link" onclick="reenviarCodigo()">
            <i class="fa fa-redo"></i>
            Não recebeu o código? Reenviar
        </a>
    </div>
    
    <script>
        // Enviar email automaticamente ao carregar a página
        window.onload = function() {
            enviarEmail();
        };
        
        function enviarEmail() {
            var loading = document.getElementById('loading');
            loading.style.display = 'block';
            
            var templateParams = {
                nome: '<%= nomeVerificacao %>',
                codigo: '<%= codigoCorreto %>',
                email: '<%= emailVerificacao %>'
            };
            
            console.log('Enviando email para:', templateParams);
            
            emailjs.send('service_ypm1nyf', 'template_rogkbcc', templateParams)
                .then(function(response) {
                    console.log('Email enviado!', response.status, response.text);
                    loading.style.display = 'none';
                    alert('Email enviado! Verifique sua caixa de entrada.');
                })
                .catch(function(error) {
                    console.log('Erro ao enviar email:', error);
                    loading.style.display = 'none';
                    alert('Erro ao enviar email: ' + JSON.stringify(error));
                });
        }
        
        function reenviarCodigo() {
            enviarEmail();
            alert('A reenviar código! Verifique seu email.');
        }
        
        // Auto-focus no próximo input
        var inputs = document.querySelectorAll('.code-input input');
        inputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                if (e.target.value.length === 1 && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
            });
            
            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && e.target.value === '' && index > 0) {
                    inputs[index - 1].focus();
                }
            });
        });
        
        // Juntar código antes de enviar
        document.getElementById('formCodigo').addEventListener('submit', function(e) {
            const codigo = Array.from(inputs).map(input => input.value).join('');
            document.getElementById('codigoFinal').value = codigo;
        });
        
        // Focus no primeiro input
        document.getElementById('d1').focus();
    </script>
</body>
</html>



