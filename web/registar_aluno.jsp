<%-- 
    Document   : registar_aluno
    Created on : 06/01/2026, 10:41:03
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page import="java.util.Random"%>
<%@page import="java.net.*"%>
<%@page import="java.io.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String mensagemSucesso = null;
    String mensagemErro = null;
    
    if (request.getMethod().equals("POST")) {
        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String telemovel = request.getParameter("telemovel");
        String morada = request.getParameter("morada");
        String dataNascimento = request.getParameter("dataNascimento");
        String categoria = request.getParameter("categoria");
        String tipoPagamento = request.getParameter("tipoPagamento");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String passwordConfirm = request.getParameter("passwordConfirm");
        String recaptchaResponse = request.getParameter("g-recaptcha-response");
        
        // Validar reCAPTCHA
        if (recaptchaResponse == null || recaptchaResponse.isEmpty()) {
            mensagemErro = "Por favor, confirme que não é um robô!";
        } else {
            // Verificar reCAPTCHA no servidor Google
            boolean captchaValido = false;
            try {
                String secretKey = "6LfdrEMsAAAAAHiYy-pImb_ejW8shrAI5d58Ps87";
                String urlStr = "https://www.google.com/recaptcha/api/siteverify";
                String params = "secret=" + secretKey + "&response=" + recaptchaResponse;
                
                URL url = new URL(urlStr);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                conn.setDoOutput(true);
                
                OutputStream os = conn.getOutputStream();
                os.write(params.getBytes());
                os.flush();
                os.close();
                
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String line;
                StringBuilder sb = new StringBuilder();
                while ((line = br.readLine()) != null) {
                    sb.append(line);
                }
                br.close();
                
                String responseStr = sb.toString();
                captchaValido = responseStr.contains("\"success\": true");
                
            } catch (Exception e) {
                e.printStackTrace();
                mensagemErro = "Erro ao validar reCAPTCHA. Tente novamente.";
            }
            
            if (!captchaValido) {
                mensagemErro = "Verificação do reCAPTCHA falhou. Tente novamente.";
            } else if (!password.equals(passwordConfirm)) {
                mensagemErro = "As senhas não coincidem!";
            } else {
                Connection connDB = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    connDB = ConexaoBD.getConnection();
                    
                    // Verificar se email já existe
                    String sqlCheck = "SELECT id FROM aluno WHERE email = ?";
                    pstmt = connDB.prepareStatement(sqlCheck);
                    pstmt.setString(1, email);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        mensagemErro = "Este email já está registado!";
                    } else {
                        rs.close();
                        pstmt.close();
                        
                        // Verificar se username já existe
                        sqlCheck = "SELECT idUtilizador FROM t_utilizador WHERE username = ?";
                        pstmt = connDB.prepareStatement(sqlCheck);
                        pstmt.setString(1, username);
                        rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            mensagemErro = "Este nome de utilizador já existe!";
                        } else {
                            rs.close();
                            pstmt.close();
                            
                            // Buscar preço da categoria escolhida
                            String sqlPreco = "SELECT precoPronto, precoParcelado FROM preco_categoria WHERE categoria = ?";
                            pstmt = connDB.prepareStatement(sqlPreco);
                            pstmt.setString(1, categoria);
                            rs = pstmt.executeQuery();
                            
                            double valorTotal = 0;
                            if (rs.next()) {
                                valorTotal = "Pronto".equals(tipoPagamento) ? 
                                            rs.getDouble("precoPronto") : 
                                            rs.getDouble("precoParcelado");
                            } else {
                                // Valores padrão caso categoria não exista
                                valorTotal = "Pronto".equals(tipoPagamento) ? 550.00 : 600.00;
                            }
                            rs.close();
                            pstmt.close();
                            
                            // Gerar código de 6 dígitos
                            Random random = new Random();
                            String codigo = String.format("%06d", random.nextInt(1000000));
                            
                            // Guardar dados temporários
                            String sqlTemp = "INSERT INTO inscricao_temp (nome, email, telemovel, morada, dataNascimento, categoria, tipoPagamento, valorTotal, username, password, codigo) " +
                                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            pstmt = connDB.prepareStatement(sqlTemp);
                            pstmt.setString(1, nome);
                            pstmt.setString(2, email);
                            pstmt.setString(3, telemovel);
                            pstmt.setString(4, morada);
                            pstmt.setDate(5, Date.valueOf(dataNascimento));
                            pstmt.setString(6, categoria);
                            pstmt.setString(7, tipoPagamento);
                            pstmt.setDouble(8, valorTotal);
                            pstmt.setString(9, username);
                            pstmt.setString(10, password);
                            pstmt.setString(11, codigo);
                            
                            int resultado = pstmt.executeUpdate();
                            
                            if (resultado > 0) {
                                // Guardar dados na sessão para página de verificação
                                session.setAttribute("email_verificacao", email);
                                session.setAttribute("nome_verificacao", nome);
                                session.setAttribute("codigo_verificacao", codigo);
                                
                                // Redirecionar para página de verificação
                                response.sendRedirect("verificar_codigo.jsp");
                                return;
                            }
                        }
                    }
                    
                } catch (Exception e) {
                    e.printStackTrace();
                    mensagemErro = "Erro ao processar inscrição: " + e.getMessage();
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (connDB != null) connDB.close();
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Inscrever-me - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    
    <!-- Google reCAPTCHA -->
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    
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
            padding: 40px 20px;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
        
        .form-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
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
        
        .form-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .form-header i {
            font-size: 4rem;
            color: #FFC107;
            margin-bottom: 15px;
        }
        
        .form-header h1 {
            color: #2C5F7C;
            font-size: 2.2rem;
            margin-bottom: 10px;
        }
        
        .form-header p {
            color: #666;
            font-size: 1rem;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 2px solid #dc3545;
        }
        
        .info-box {
            background: rgba(255, 193, 7, 0.1);
            border: 2px solid #FFC107;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
        }
        
        .info-box h3 {
            color: #2C5F7C;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        label {
            font-weight: 600;
            margin-bottom: 8px;
            color: #2C5F7C;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        label i {
            color: #FFC107;
        }
        
        .required {
            color: #dc3545;
        }
        
        input, select {
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            font-family: 'Work Sans', sans-serif;
            transition: all 0.3s;
        }
        
        input:focus, select:focus {
            outline: none;
            border-color: #FFC107;
            box-shadow: 0 0 0 4px rgba(255, 193, 7, 0.1);
        }
        
        .radio-group {
            display: flex;
            gap: 20px;
            margin-top: 8px;
        }
        
        .radio-option {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px;
            border: 2px solid #ddd;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
            flex: 1;
        }
        
        .radio-option:hover {
            border-color: #FFC107;
            background: rgba(255, 193, 7, 0.05);
        }
        
        .radio-option input[type="radio"] {
            width: 20px;
            height: 20px;
            margin: 0;
            padding: 0;
        }
        
        .recaptcha-container {
            display: flex;
            justify-content: center;
            margin: 30px 0;
            padding: 20px;
            background: rgba(44, 95, 124, 0.05);
            border-radius: 10px;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            margin-top: 30px;
        }
        
        .btn {
            padding: 14px 30px;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
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
        
        #precoSelecionado {
            background: rgba(40, 167, 69, 0.1);
            border: 2px solid #28a745;
            color: #155724;
            padding: 15px 20px;
            border-radius: 10px;
            margin-top: 15px;
            font-weight: 700;
            text-align: center;
            font-size: 1.2rem;
        }
        
        @media (max-width: 768px) {
            .form-card {
                padding: 25px 20px;
            }
            
            .form-header h1 {
                font-size: 1.8rem;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .btn-group {
                flex-direction: column;
            }
            
            .radio-group {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="form-card">
            <div class="form-header">
                <i class="fa fa-user-plus"></i>
                <h1>Inscrever-me na Escola</h1>
                <p>Preencha os dados abaixo para criar sua conta</p>
            </div>
            
            <% if (mensagemErro != null) { %>
                <div class="alert alert-error">
                    <i class="fa fa-exclamation-triangle fa-2x"></i>
                    <div>
                        <strong>Erro!</strong><br>
                        <%= mensagemErro %>
                    </div>
                </div>
            <% } %>
            
            <div class="info-box">
                <h3>
                    <i class="fa fa-info-circle"></i>
                    Informação Importante
                </h3>
                <p style="font-size: 1rem; color: #666; line-height: 1.8;">
                    ⚠️ <strong>Atenção:</strong> Após preencher o formulário, receberá um <strong>código de verificação por email</strong>. A sua conta será ativada após a confirmação do primeiro pagamento pela escola.
                </p>
            </div>
            
            <form method="POST" action="registar_aluno.jsp" id="formInscricao">
                <h3 style="color: #2C5F7C; margin-bottom: 15px; border-bottom: 2px solid #FFC107; padding-bottom: 10px;">
                    📝 Dados Pessoais
                </h3>
                
                <div class="form-grid">
                    <div class="form-group full-width">
                        <label>
                            <i class="fa fa-user"></i>
                            Nome Completo <span class="required">*</span>
                        </label>
                        <input type="text" name="nome" required placeholder="Ex: João Silva">
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <i class="fa fa-envelope"></i>
                            Email <span class="required">*</span>
                        </label>
                        <input type="email" name="email" required placeholder="joao@exemplo.com">
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <i class="fa fa-phone"></i>
                            Telemóvel <span class="required">*</span>
                        </label>
                        <input type="text" name="telemovel" required placeholder="912345678">
                    </div>
                    
                    <div class="form-group full-width">
                        <label>
                            <i class="fa fa-home"></i>
                            Morada <span class="required">*</span>
                        </label>
                        <input type="text" name="morada" required placeholder="Rua, Número, Código Postal, Cidade">
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <i class="fa fa-birthday-cake"></i>
                            Data de Nascimento <span class="required">*</span>
                        </label>
                        <input type="date" name="dataNascimento" required>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <i class="fa fa-id-card"></i>
                            Categoria <span class="required">*</span>
                        </label>
                        <select name="categoria" id="categoria" required onchange="atualizarPreco()">
                            <option value="">Selecione...</option>
                            <%
                            Connection connCat = null;
                            PreparedStatement pstmtCat = null;
                            ResultSet rsCat = null;
                            try {
                                connCat = ConexaoBD.getConnection();
                                String sqlCat = "SELECT categoria, descricao FROM preco_categoria ORDER BY categoria";
                                pstmtCat = connCat.prepareStatement(sqlCat);
                                rsCat = pstmtCat.executeQuery();
                                while (rsCat.next()) {
                            %>
                            <option value="<%= rsCat.getString("categoria") %>">
                                <%= rsCat.getString("categoria") %> - <%= rsCat.getString("descricao") %>
                            </option>
                            <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rsCat != null) rsCat.close();
                                if (pstmtCat != null) pstmtCat.close();
                                if (connCat != null) connCat.close();
                            }
                            %>
                        </select>
                    </div>
                </div>
                
                <h3 style="color: #2C5F7C; margin: 25px 0 15px; border-bottom: 2px solid #FFC107; padding-bottom: 10px;">
                    💰 Forma de Pagamento
                </h3>
                
                <div class="form-group">
                    <label>
                        <i class="fa fa-credit-card"></i>
                        Escolha a forma de pagamento <span class="required">*</span>
                    </label>
                    <div class="radio-group">
                        <label class="radio-option">
                            <input type="radio" name="tipoPagamento" value="Pronto" required onchange="atualizarPreco()">
                            <span><strong>Pronto Pagamento</strong><br><small>Pagamento único</small></span>
                        </label>
                        <label class="radio-option">
                            <input type="radio" name="tipoPagamento" value="Parcelado" checked required onchange="atualizarPreco()">
                            <span><strong>Parcelado</strong><br><small>6 prestações</small></span>
                        </label>
                    </div>
                    <div id="precoSelecionado" style="display: none;"></div>
                </div>
                
                <h3 style="color: #2C5F7C; margin: 25px 0 15px; border-bottom: 2px solid #FFC107; padding-bottom: 10px;">
                    🔐 Dados de Acesso
                </h3>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label>
                            <i class="fa fa-user-circle"></i>
                            Nome de Utilizador <span class="required">*</span>
                        </label>
                        <input type="text" name="username" required placeholder="Ex: joaosilva">
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <i class="fa fa-lock"></i>
                            Senha <span class="required">*</span>
                        </label>
                        <input type="password" name="password" required placeholder="Mínimo 6 caracteres">
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <i class="fa fa-lock"></i>
                            Confirmar Senha <span class="required">*</span>
                        </label>
                        <input type="password" name="passwordConfirm" required placeholder="Digite a senha novamente">
                    </div>
                </div>
                
                <h3 style="color: #2C5F7C; margin: 25px 0 15px; border-bottom: 2px solid #FFC107; padding-bottom: 10px;">
                    🤖 Verificação de Segurança
                </h3>
                
                <div class="recaptcha-container">
                    <div class="g-recaptcha" data-sitekey="6LfdrEMsAAAAAAHsOZIH2J66BBvtPVmmOjxEyIYK"></div>
                </div>
                
                <div class="btn-group">
                    <a href="index.jsp" class="btn btn-secondary">
                        <i class="fa fa-times"></i>
                        Cancelar
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa fa-check"></i>
                        Continuar
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // Dados dos preços (carregados do servidor)
        const precos = {
            <%
            Connection connJS = null;
            PreparedStatement pstmtJS = null;
            ResultSet rsJS = null;
            try {
                connJS = ConexaoBD.getConnection();
                String sqlJS = "SELECT * FROM preco_categoria";
                pstmtJS = connJS.prepareStatement(sqlJS);
                rsJS = pstmtJS.executeQuery();
                boolean first = true;
                while (rsJS.next()) {
                    if (!first) out.print(",");
                    out.print("'" + rsJS.getString("categoria") + "': {");
                    out.print("pronto: " + rsJS.getDouble("precoPronto") + ",");
                    out.print("parcelado: " + rsJS.getDouble("precoParcelado"));
                    out.print("}");
                    first = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rsJS != null) rsJS.close();
                if (pstmtJS != null) pstmtJS.close();
                if (connJS != null) connJS.close();
            }
            %>
        };
        
        function atualizarPreco() {
            const categoria = document.getElementById('categoria').value;
            const tipoPagamento = document.querySelector('input[name="tipoPagamento"]:checked');
            const precoDiv = document.getElementById('precoSelecionado');
            
            if (categoria && tipoPagamento && precos[categoria]) {
                const tipo = tipoPagamento.value;
                const valor = tipo === 'Pronto' ? precos[categoria].pronto : precos[categoria].parcelado;
                const prestacoes = tipo === 'Parcelado' ? ' (6x de €' + (valor / 6).toFixed(2) + ')' : '';
                
                precoDiv.innerHTML = '💰 Valor Total: €' + valor.toFixed(2) + prestacoes;
                precoDiv.style.display = 'block';
            } else {
                precoDiv.style.display = 'none';
            }
        }
    </script>
</body>
</html>

