<%-- 
    Document   : listar_pagamentos
    Created on : 06/01/2026, 09:24:51
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verificar login
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String tipo = (String) session.getAttribute("tipo");
    String username = (String) session.getAttribute("username");
    
    // Buscar idAluno DIRETAMENTE da tabela t_utilizador
    Integer idAluno = null;
    if ("Aluno".equals(tipo)) {
        Connection connAluno = null;
        PreparedStatement pstmtAluno = null;
        ResultSet rsAluno = null;
        try {
            connAluno = ConexaoBD.getConnection();
            String sqlAluno = "SELECT idAluno FROM t_utilizador WHERE username = ?";
            pstmtAluno = connAluno.prepareStatement(sqlAluno);
            pstmtAluno.setString(1, username);
            rsAluno = pstmtAluno.executeQuery();
            if (rsAluno.next()) {
                idAluno = rsAluno.getInt("idAluno");
                // DEBUG - Remover depois
                System.out.println("=== DEBUG PAGAMENTOS ===");
                System.out.println("username: " + username);
                System.out.println("idAluno encontrado: " + idAluno);
            } else {
                System.out.println("ERRO: Nenhum idAluno encontrado para username " + username);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rsAluno != null) rsAluno.close();
            if (pstmtAluno != null) pstmtAluno.close();
            if (connAluno != null) connAluno.close();
        }
    }
    
    // Mensagem de sucesso
    String msgSucesso = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Pagamentos - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Work Sans', sans-serif; background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%); background-attachment: fixed; color: white; min-height: 100vh; }
        .topbar { background: rgba(0,0,0,0.4); backdrop-filter: blur(10px); padding: 15px 0; border-bottom: 1px solid rgba(255,193,7,0.2); }
        .topbar .container { max-width: 1400px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; }
        .topbar .user-info { color: white; display: flex; align-items: center; gap: 10px; }
        .topbar .user-info i { color: #FFC107; }
        .btn-sair { background: rgba(128,0,32,0.8); color: white; padding: 10px 25px; border-radius: 10px; text-decoration: none; font-weight: 600; transition: all 0.3s; display: inline-flex; align-items: center; gap: 8px; border: 1px solid rgba(255,193,7,0.3); }
        .btn-sair:hover { background: #800020; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(128,0,32,0.5); }
        .container { max-width: 1400px; margin: 0 auto; padding: 40px 20px; }
        .logo-link { display: block; text-align: center; margin-bottom: 30px; }
        .logo-link img { height: 60px; width: auto; filter: drop-shadow(0 0 10px rgba(255,193,7,0.3)); }
        .content-card { background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border: 1px solid rgba(255,193,7,0.2); border-radius: 20px; padding: 40px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; flex-wrap: wrap; gap: 20px; }
        .page-header h2 { color: white; font-size: 2rem; display: flex; align-items: center; gap: 15px; }
        .page-header h2 i { color: #FFC107; }
        .btn { padding: 12px 25px; border: none; border-radius: 10px; font-size: 1rem; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-adicionar { background: linear-gradient(135deg, #FFC107 0%, #FFB300 100%); color: #1a3a4d; padding: 12px 25px; border-radius: 10px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-adicionar:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255,193,7,0.4); }
        .alert-success { background: rgba(76,175,80,0.2); border: 1px solid #4CAF50; color: #4CAF50; padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; display: flex; align-items: center; gap: 10px; }
        .alert-error { background: rgba(244,67,54,0.2); border: 1px solid #F44336; color: #F44336; padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; display: flex; align-items: center; gap: 10px; }
        /* RESUMO ALUNO */
        .resumo-pagamento { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,193,7,0.2); border-radius: 15px; padding: 30px; margin-bottom: 30px; }
        .resumo-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
        .resumo-header h2 { color: white; font-size: 1.5rem; }
        .status-badge { padding: 10px 20px; border-radius: 25px; font-weight: 700; font-size: 1rem; }
        .status-pago { background: rgba(76,175,80,0.3); color: #4CAF50; border: 1px solid #4CAF50; }
        .status-pendente { background: rgba(244,67,54,0.3); color: #F44336; border: 1px solid #F44336; }
        .resumo-valores { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .valor-box { text-align: center; padding: 20px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 10px; }
        .valor-box .label { color: rgba(255,255,255,0.6); font-size: 0.9rem; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px; }
        .valor-box .valor { color: white; font-size: 2rem; font-weight: 700; }
        .valor-box.pago .valor { color: #4CAF50; }
        .valor-box.falta .valor { color: #F44336; }
        .progress-bar-container { background: rgba(255,255,255,0.1); border-radius: 25px; height: 30px; overflow: hidden; margin-bottom: 10px; }
        .progress-bar-fill { height: 100%; display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; transition: width 0.5s ease; }
        .progress-bar-fill.completo { background: linear-gradient(90deg, #4CAF50, #45a049); }
        .progress-bar-fill.parcial { background: linear-gradient(90deg, #FFC107, #FFB300); }
        .progress-bar-fill.inicio { background: linear-gradient(90deg, #F44336, #d32f2f); }
        /* TABELA */
        .table-container { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,193,7,0.1); border-radius: 15px; padding: 30px; overflow-x: auto; }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 15px; }
        .table-header h2 { color: white; font-size: 1.5rem; display: flex; align-items: center; gap: 10px; }
        .table-header h2 i { color: #FFC107; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; flex-wrap: wrap; gap: 20px; }
        .page-header h1 { color: white; font-size: 2rem; display: flex; align-items: center; gap: 15px; }
        .page-header h1 i { color: #FFC107; }
        .logo-link { display: block; text-align: center; margin-bottom: 30px; }
        .logo-link img { height: 60px; width: auto; filter: drop-shadow(0 0 10px rgba(255,193,7,0.3)); }
        .content-card { background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border: 1px solid rgba(255,193,7,0.2); border-radius: 20px; padding: 40px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
        .btn-voltar { background: rgba(255,255,255,0.1); color: white; padding: 12px 25px; border-radius: 10px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; border: 2px solid rgba(255,255,255,0.3); transition: all 0.3s; }
        .btn-voltar:hover { background: rgba(255,255,255,0.2); border-color: #FFC107; transform: translateY(-2px); }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%); }
        th { padding: 15px; text-align: left; font-weight: 600; color: white; }
        tbody tr { border-bottom: 1px solid rgba(255,255,255,0.1); transition: all 0.3s; }
        tbody tr:hover { background: rgba(255,193,7,0.1); }
        td { padding: 15px; color: rgba(255,255,255,0.9); }
        .search-bar { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,.06); border:1px solid rgba(255,193,7,.25); border-radius:12px; padding:10px 16px; margin-bottom:20px; }
        .search-bar i { color:#FFC107; font-size:1rem; flex-shrink:0; }
        .search-bar input { background:none; border:none; outline:none; color:white; font-family:'Work Sans',sans-serif; font-size:.95rem; width:100%; }
        .search-bar input::placeholder { color:rgba(255,255,255,.35); }
        .search-contador { font-size:.8rem; color:rgba(255,255,255,.45); white-space:nowrap; }
        .sem-resultados { display:none; text-align:center; padding:30px; color:rgba(255,255,255,.4); }


        .btn-edit { background: #FFC107; color: #1a3a4d; padding: 8px 15px; font-size: 0.9rem; border-radius: 10px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-edit:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255,193,7,0.4); }
        .btn-delete { background: rgba(244,67,54,0.8); color: white; padding: 8px 15px; font-size: 0.9rem; border-radius: 10px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-delete:hover { background: #F44336; transform: translateY(-2px); }
        .acoes { display: flex; gap: 10px; }
        @media (max-width: 768px) { .topbar .container { flex-direction: column; gap: 10px; } table { font-size: 0.9rem; } th, td { padding: 10px 8px; } }
    </style>
</head>
<body>
    <!-- TOPBAR -->
    <div class="topbar">
        <div class="container">
            <div class="user-info">
                <% if ("Admin".equals(tipo)) { %>
                    <i class="fa fa-user-shield"></i>
                    <span><strong><%= username %></strong> (Admin)</span>
                <% } else if ("Instrutor".equals(tipo)) { %>
                    <i class="fa fa-user-tie"></i>
                    <span><strong><%= username %></strong> (Instrutor)</span>
                <% } else { %>
                    <i class="fa fa-user-graduate"></i>
                    <span><strong><%= username %></strong> (Aluno)</span>
                <% } %>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <!-- CONTAINER -->
    <div class="container">
        <!-- LOGO -->
        <% if ("Admin".equals(tipo)) { %>
            <a href="dashboard.jsp" class="logo-link">
        <% } else if ("Instrutor".equals(tipo)) { %>
            <a href="dashboard_instrutor.jsp" class="logo-link">
        <% } else { %>
            <a href="dashboard_aluno.jsp" class="logo-link">
        <% } %>
            <img src="image/logo_mini.png" alt="Drive School">
        </a>

        <div class="content-card">
            <!-- HEADER -->
            <div class="page-header">
                <h1>
                    <i class="fa fa-money-bill-wave"></i>
                    <%= "Aluno".equals(tipo) ? "Meus Pagamentos" : "Gestão de Pagamentos" %>
                </h1>
                <div style="display:flex; gap:15px; align-items:center;">
                    <% if ("Admin".equals(tipo)) { %>
                        <a href="adicionar_pagamento.jsp" class="btn-adicionar">
                            <i class="fa fa-plus"></i>
                            Adicionar Pagamento
                        </a>
                        <a href="dashboard.jsp" class="btn-voltar">
                            <i class="fa fa-arrow-left"></i>
                            Voltar
                        </a>
                    <% } else if ("Instrutor".equals(tipo)) { %>
                        <a href="dashboard_instrutor.jsp" class="btn-voltar">
                            <i class="fa fa-arrow-left"></i>
                            Voltar
                        </a>
                    <% } else { %>
                        <a href="dashboard_aluno.jsp" class="btn-voltar">
                            <i class="fa fa-arrow-left"></i>
                            Voltar
                        </a>
                    <% } %>
                </div>
            </div>
        
            <% if ("success".equals(msgSucesso)) { %>
                <div class="alert-success">
                    <i class="fa fa-check-circle fa-2x"></i>
                    <strong>Pagamento registado com sucesso!</strong>
                </div>
            <% } %>
            
            <% if ("Aluno".equals(tipo) && idAluno == null) { %>
                <div class="alert-error">
                    <i class="fa fa-exclamation-triangle fa-2x"></i>
                    <div>
                        <strong>Erro de Configuração!</strong><br>
                        Sua conta de aluno não está corretamente vinculada. Entre em contato com a administração.<br>
                        <small>(username: <%= username %>, idAluno: null)</small>
                    </div>
                </div>
            <% } %>
            
            <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            double valorTotal = 0;
            double valorPago = 0;
            String tipoPagamento = "";
            
            // SE FOR ALUNO, mostrar resumo
            if ("Aluno".equals(tipo) && idAluno != null) {
                try {
                    conn = ConexaoBD.getConnection();
                    
                    // Buscar info do aluno
                    String sqlAluno = "SELECT tipoPagamento, valorTotal FROM aluno WHERE id = ?";
                    pstmt = conn.prepareStatement(sqlAluno);
                    pstmt.setInt(1, idAluno);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        tipoPagamento = rs.getString("tipoPagamento");
                        valorTotal = rs.getDouble("valorTotal");
                    }
                    rs.close();
                    pstmt.close();
                    
                    // Calcular valor pago
                    String sqlPago = "SELECT SUM(valor) as total FROM pagamento WHERE idAluno = ?";
                    pstmt = conn.prepareStatement(sqlPago);
                    pstmt.setInt(1, idAluno);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        valorPago = rs.getDouble("total");
                    }
                    
                    double valorFalta = valorTotal - valorPago;
                    double percentual = (valorTotal > 0) ? (valorPago / valorTotal) * 100 : 0;
                    boolean pagamentoCompleto = valorPago >= valorTotal;
            %>
            
            <!-- RESUMO DO ALUNO -->
            <div class="resumo-pagamento">
                <div class="resumo-header">
                    <h2>📊 Resumo do Pagamento</h2>
                    <div class="status-badge <%= pagamentoCompleto ? "status-pago" : "status-pendente" %>">
                        <%= pagamentoCompleto ? "✅ TOTALMENTE PAGO" : "⏳ PAGAMENTO PENDENTE" %>
                    </div>
                </div>
                
                <div class="resumo-valores">
                    <div class="valor-box">
                        <div class="label">Tipo de Pagamento</div>
                        <div class="valor" style="font-size: 1.2rem;">
                            <%= tipoPagamento != null ? tipoPagamento : "Parcelado" %>
                        </div>
                    </div>
                    
                    <div class="valor-box">
                        <div class="label">Valor Total</div>
                        <div class="valor">€<%= String.format("%.2f", valorTotal) %></div>
                    </div>
                    
                    <div class="valor-box pago">
                        <div class="label">Já Pago</div>
                        <div class="valor">€<%= String.format("%.2f", valorPago) %></div>
                    </div>
                    
                    <div class="valor-box falta">
                        <div class="label">Falta Pagar</div>
                        <div class="valor">€<%= String.format("%.2f", valorFalta) %></div>
                    </div>
                </div>
                
                <div class="progress-bar-container">
                    <div class="progress-bar-fill <%= percentual >= 100 ? "completo" : (percentual >= 50 ? "parcial" : "inicio") %>" 
                         style="width: <%= Math.min(percentual, 100) %>%">
                        <%= String.format("%.0f%%", percentual) %>
                    </div>
                </div>
                <p style="text-align: center; color: #666; margin-top: 10px;">
                    Progresso do pagamento: <%= String.format("%.0f%%", percentual) %> completo
                </p>
            </div>
            
            <%
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            }
            
            // LISTAR PAGAMENTOS
            if (!("Aluno".equals(tipo) && idAluno == null)) {
                try {
                    conn = ConexaoBD.getConnection();
                    String sql = "";
                    
                    if ("Aluno".equals(tipo) && idAluno != null) {
                        // Aluno vê só SEUS pagamentos
                        sql = "SELECT p.*, a.nome as nomeAluno FROM pagamento p " +
                              "JOIN aluno a ON p.idAluno = a.id " +
                              "WHERE p.idAluno = ? " +
                              "ORDER BY p.dataPagamento DESC";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, idAluno);
                        
                        System.out.println("Query Aluno: WHERE idAluno = " + idAluno);
                    } else {
                        // Admin e Instrutor veem TODOS
                        sql = "SELECT p.*, a.nome as nomeAluno FROM pagamento p " +
                              "JOIN aluno a ON p.idAluno = a.id " +
                              "ORDER BY p.dataPagamento DESC";
                        pstmt = conn.prepareStatement(sql);
                        
                        System.out.println("Query Admin/Instrutor: SEM FILTRO (todos)");
                    }
                    
                    rs = pstmt.executeQuery();
            %>
            
            <!-- BARRA DE PESQUISA -->
            <div class="search-bar">
                <i class="fa fa-search"></i>
                <input type="text" id="campoPesquisa" placeholder="Pesquisar por nome do aluno..." onkeyup="filtrarTabela()">
                <span class="search-contador" id="contadorResultados"></span>
            </div>

            <div class="table-container">
                <div class="table-header">
                    <h2>📋 <%= "Aluno".equals(tipo) ? "Histórico dos Meus Pagamentos" : "Lista de Todos os Pagamentos" %></h2>
                    
                    <% if ("Admin".equals(tipo)) { %>
                        <a href="adicionar_pagamento.jsp" class="btn-adicionar">
                            <i class="fa fa-plus"></i>
                            Adicionar Pagamento
                        </a>
                    <% } %>
                </div>
                
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <% if (!"Aluno".equals(tipo)) { %>
                                <th>Aluno</th>
                            <% } %>
                            <th>Valor</th>
                            <th>Método</th>
                            <th>Referência</th>
                            <th>Data</th>
                            <th>Descrição</th>
                            <% if ("Admin".equals(tipo)) { %>
                                <th>Ações</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (!rs.isBeforeFirst()) {
                        %>
                        <tr>
                            <td colspan="<%= "Aluno".equals(tipo) ? "6" : "7" %>" style="text-align: center; padding: 40px; color: #999;">
                                <i class="fa fa-inbox fa-3x" style="display: block; margin-bottom: 15px;"></i>
                                Nenhum pagamento registado
                            </td>
                        </tr>
                        <%
                        } else {
                            while (rs.next()) {
                        %>
                        <tr class="pag-row" data-aluno="<%= rs.getString("nomeAluno") != null ? rs.getString("nomeAluno").toLowerCase() : ""%>">
                            <td><strong>#<%= rs.getInt("id") %></strong></td>
                            <% if (!"Aluno".equals(tipo)) { %>
                                <td><%= rs.getString("nomeAluno") %></td>
                            <% } %>
                            <td><strong style="color: #28a745;">€<%= String.format("%.2f", rs.getDouble("valor")) %></strong></td>
                            <td><%= rs.getString("metodo") %></td>
                            <td><%= rs.getString("referenciaPagamento") != null ? rs.getString("referenciaPagamento") : "-" %></td>
                            <td><%= rs.getDate("dataPagamento") %></td>
                            <td><%= rs.getString("descricao") %></td>
                            <% if ("Admin".equals(tipo)) { %>
                            <td>
                                <div class="acoes">
                                    <a href="editar_pagamento.jsp?id=<%= rs.getInt("id") %>" class="btn-edit">
                                        <i class="fa fa-edit"></i> Editar
                                    </a>
                                    <a href="eliminar_pagamento.jsp?id=<%= rs.getInt("id") %>" class="btn-delete">
                                        <i class="fa fa-trash"></i> Eliminar
                                    </a>
                                </div>
                            </td>
                            <% } %>
                        </tr>
                        <%
                            }
                        }
                        %>
                    </tbody>
                </table>
            </div>
            
            <%
                } catch (Exception e) {
                    e.printStackTrace();
            %>
            <div class="table-container">
                <p style="color: #dc3545; text-align: center; padding: 20px;">
                    <i class="fa fa-exclamation-triangle"></i>
                    Erro ao carregar pagamentos: <%= e.getMessage() %>
                </p>
            </div>
            <%
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            }
            %>
        </div><!-- content-card -->
    </div><!-- container -->

    <script>
    function filtrarTabela() {
        var input = document.getElementById('campoPesquisa').value.toLowerCase();
        var rows = document.querySelectorAll('.pag-row');
        var count = 0;
        rows.forEach(function(row) {
            var match = row.getAttribute('data-aluno').includes(input);
            row.style.display = match ? '' : 'none';
            if (match) count++;
        });
        var total = rows.length;
        var contador = document.getElementById('contadorResultados');
        contador.textContent = input === '' ? total + ' pagamentos' : count + ' de ' + total + ' resultados';
        document.getElementById('semResultados').style.display = count === 0 && input !== '' ? 'block' : 'none';
    }
    window.onload = function() {
        var total = document.querySelectorAll('.pag-row').length;
        document.getElementById('contadorResultados').textContent = total + ' pagamentos';
    };
    </script>
    <script>
    function filtrarTabela() {
        var input = document.getElementById('campoPesquisa').value.toLowerCase();
        var rows = document.querySelectorAll('.pag-row');
        var count = 0;
        rows.forEach(function(row) {
            var match = row.getAttribute("data-aluno").includes(input);
            row.style.display = match ? '' : 'none';
            if (match) count++;
        });
        var total = rows.length;
        document.getElementById('contadorResultados').textContent = input === '' ? total + ' pagamentos' : count + ' de ' + total + ' resultados';
        document.getElementById('semResultados').style.display = count === 0 && input !== '' ? 'block' : 'none';
    }
    window.onload = function() {
        document.getElementById('contadorResultados').textContent = document.querySelectorAll('.pag-row').length + ' pagamentos';
    };
    </script>
</body>
</html>











