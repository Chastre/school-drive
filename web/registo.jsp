<%-- 
    Document   : registo
    Created on : 26/01/2026, 09:24:11
    Author     : pmnch
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Criar Conta - Drive School</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Work Sans',sans-serif; background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%); min-height:100vh; display:flex; align-items:center; justify-content:center; color:white; padding:30px 20px; }
        .card { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.2); border-radius:22px; padding:40px; width:100%; max-width:560px; box-shadow:0 8px 32px rgba(0,0,0,.3); }
        .card-header { text-align:center; margin-bottom:32px; }
        .card-header .icone { width:70px; height:70px; border-radius:18px; background:linear-gradient(135deg,rgba(255,193,7,.3),rgba(255,193,7,.1)); border:1px solid rgba(255,193,7,.3); display:flex; align-items:center; justify-content:center; margin:0 auto 16px; }
        .card-header .icone i { font-size:1.8rem; color:#FFC107; }
        .card-header h1 { font-size:1.6rem; font-weight:800; color:white; margin-bottom:6px; }
        .card-header p { color:rgba(255,255,255,.5); font-size:.88rem; }

        .secao-titulo { font-size:.72rem; text-transform:uppercase; letter-spacing:1px; color:#FFC107; font-weight:700; margin:24px 0 14px; display:flex; align-items:center; gap:8px; }
        .secao-titulo::after { content:''; flex:1; height:1px; background:rgba(255,193,7,.2); }

        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .form-group { margin-bottom:14px; }
        .form-group label { display:flex; align-items:center; gap:7px; font-size:.82rem; font-weight:600; color:rgba(255,255,255,.8); margin-bottom:7px; }
        .form-group label i { color:#FFC107; width:14px; }
        .form-group input, .form-group select { width:100%; padding:11px 14px; border:1px solid rgba(255,193,7,.25); border-radius:10px; background:rgba(255,255,255,.06); color:white; font-size:.92rem; font-family:'Work Sans',sans-serif; transition:all .3s; }
        .form-group input:focus, .form-group select:focus { outline:none; border-color:#FFC107; background:rgba(255,255,255,.1); }
        .form-group input::placeholder { color:rgba(255,255,255,.3); }
        .form-group select option { background:#1a3a4d; }

        .alert { border-radius:12px; padding:14px 18px; margin-bottom:20px; display:flex; align-items:center; gap:10px; font-size:.88rem; }
        .alert-erro { background:rgba(244,67,54,.15); border:1px solid rgba(244,67,54,.4); color:#f5a0a8; }
        .alert i { flex-shrink:0; }

        .btn-registar { width:100%; padding:14px; background:linear-gradient(135deg,#FFC107,#FFB300); color:#1a3a4d; border:none; border-radius:12px; font-size:1rem; font-weight:800; cursor:pointer; transition:all .3s; margin-top:8px; display:flex; align-items:center; justify-content:center; gap:8px; font-family:'Work Sans',sans-serif; }
        .btn-registar:hover { transform:translateY(-2px); box-shadow:0 8px 25px rgba(255,193,7,.4); }

        .link { text-align:center; margin-top:20px; font-size:.88rem; color:rgba(255,255,255,.5); }
        .link a { color:#FFC107; text-decoration:none; font-weight:600; }
        .link a:hover { text-decoration:underline; }

        @media(max-width:480px){ .form-row{ grid-template-columns:1fr; } }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header">
            <div class="icone"><i class="fa fa-user-plus"></i></div>
            <h1>Criar Conta</h1>
            <p>Preenche os teus dados para te inscreveres</p>
        </div>

        <%
            String erro = request.getParameter("erro");
            if ("campos".equals(erro)) {
        %>
        <div class="alert alert-erro"><i class="fa fa-exclamation-circle"></i>Por favor, preenche todos os campos obrigatórios!</div>
        <% } else if ("duplicado".equals(erro)) { %>
        <div class="alert alert-erro"><i class="fa fa-exclamation-circle"></i>Este email ou username já está registado!</div>
        <% } else if ("bd".equals(erro)) { %>
        <div class="alert alert-erro"><i class="fa fa-exclamation-circle"></i>Erro ao criar conta. Tenta novamente!</div>
        <% } %>

        <form action="processar_registo.jsp" method="post">

            <div class="secao-titulo"><i class="fa fa-user"></i> Dados Pessoais</div>

            <div class="form-row">
                <div class="form-group">
                    <label><i class="fa fa-id-card"></i>Nome Completo *</label>
                    <input type="text" name="nome" required placeholder="ex: João Silva">
                </div>
                <div class="form-group">
                    <label><i class="fa fa-phone"></i>Telemóvel *</label>
                    <input type="tel" name="telemovel" required placeholder="ex: 912345678" maxlength="9">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label><i class="fa fa-calendar"></i>Data de Nascimento *</label>
                    <input type="date" name="dataNascimento" required>
                </div>
                <div class="form-group">
                    <label><i class="fa fa-car"></i>Categoria *</label>
                    <select name="categoria" required>
                        <option value="" disabled selected>Escolher...</option>
                        <option value="B">Categoria B (Automóvel)</option>
                        <option value="A">Categoria A (Mota)</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label><i class="fa fa-map-marker-alt"></i>Morada *</label>
                <input type="text" name="morada" required placeholder="ex: Rua das Flores 123, Porto">
            </div>

            <div class="secao-titulo"><i class="fa fa-lock"></i> Dados de Acesso</div>

            <div class="form-group">
                <label><i class="fa fa-user"></i>Nome de Utilizador *</label>
                <input type="text" name="username" required placeholder="ex: joao123">
            </div>

            <div class="form-group">
                <label><i class="fa fa-envelope"></i>Email *</label>
                <input type="email" name="email" required placeholder="ex: joao@gmail.com">
            </div>

            <div class="form-group">
                <label><i class="fa fa-lock"></i>Password *</label>
                <input type="password" name="password" required placeholder="Mínimo 6 caracteres" minlength="6">
            </div>

            <button type="submit" class="btn-registar">
                <i class="fa fa-check"></i>Criar Conta
            </button>
        </form>

        <div class="link">
            Já tens conta? <a href="login.jsp">Fazer Login</a> &nbsp;|&nbsp; <a href="index.jsp">Voltar ao início</a>
        </div>
    </div>
</body>
</html>
