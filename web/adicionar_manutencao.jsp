<%-- 
    Document   : adicionar_manutencao
    Created on : 18/12/2025, 00:19:34
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Admin".equals(tipo)) { response.sendRedirect("login.jsp"); return; }
    String username = (String) session.getAttribute("username");

    if (request.getMethod().equals("POST")) {
        String idVeiculo = request.getParameter("idVeiculo");
        String dataManutencao = request.getParameter("dataManutencao");
        String quilometragem = request.getParameter("quilometragem");
        String tipoMan = request.getParameter("tipo");
        String descricao = request.getParameter("descricao");
        String custo = request.getParameter("custo");
        String oficina = request.getParameter("oficina");
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = ConexaoBD.getConnection();
            String sql = "INSERT INTO manutencao (idVeiculo, data, tipo, descricao, custo) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(idVeiculo));
            pstmt.setDate(2, Date.valueOf(dataManutencao));
            pstmt.setString(3, tipoMan);
            pstmt.setString(4, descricao);
            pstmt.setDouble(5, Double.parseDouble(custo));
            int resultado = pstmt.executeUpdate();
            if (resultado > 0) { response.sendRedirect("listar_manutencoes.jsp?msg=success"); return; }
            else { response.sendRedirect("adicionar_manutencao.jsp?msg=error"); return; }
        } catch (Exception e) {
            e.printStackTrace(); response.sendRedirect("adicionar_manutencao.jsp?msg=error"); return;
        } finally {
            try { if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registar Manutenção - Escola de Condução</title>
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #1a0a2e 0%, #2d1b4e 30%, #4a0e2d 70%, #1a0a2e 100%); min-height: 100vh; }
        .topbar { background: rgba(0,0,0,0.4); backdrop-filter: blur(10px); padding: 14px 30px; border-bottom: 1px solid rgba(255,193,7,0.2); display: flex; justify-content: space-between; align-items: center; }
        .topbar-left { display: flex; align-items: center; gap: 15px; }
        .topbar-left img { height: 44px; filter: drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .user-info { display: flex; align-items: center; gap: 8px; color: rgba(255,255,255,0.85); }
        .user-info i { color: #FFC107; }
        .btn-sair { background: rgba(128,0,32,0.8); color: white; padding: 9px 22px; border-radius: 10px; text-decoration: none; font-weight: 600; border: 1px solid rgba(255,193,7,0.3); display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-sair:hover { background: #800020; transform: translateY(-2px); }
        .container { max-width: 860px; margin: 40px auto; padding: 0 20px; }
        .form-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,193,7,0.2); border-radius: 20px; padding: 40px; backdrop-filter: blur(10px); box-shadow: 0 20px 60px rgba(0,0,0,0.4); }
        .form-header { text-align: center; margin-bottom: 35px; }
        .icon-wrap { width: 65px; height: 65px; background: linear-gradient(135deg, #FFC107, #FF8C00); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 15px; box-shadow: 0 8px 25px rgba(255,193,7,0.35); }
        .icon-wrap i { font-size: 1.6rem; color: #1a0a2e; }
        .form-header h1 { font-size: 1.8rem; font-weight: 800; color: white; margin-bottom: 6px; }
        .form-header p { color: rgba(255,255,255,0.55); }
        .alert { display: flex; align-items: center; gap: 15px; padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; }
        .alert-success { background: rgba(40,167,69,0.2); border: 1px solid rgba(40,167,69,0.4); color: #a8e6b5; }
        .alert-error { background: rgba(220,53,69,0.2); border: 1px solid rgba(220,53,69,0.4); color: #f5a0a8; }
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 22px; margin-bottom: 35px; }
        .form-group { display: flex; flex-direction: column; }
        .full-width { grid-column: 1 / -1; }
        label { font-weight: 600; margin-bottom: 8px; color: rgba(255,255,255,0.8); font-size: 0.88rem; text-transform: uppercase; letter-spacing: 0.5px; display: flex; align-items: center; gap: 7px; }
        label i { color: #FFC107; }
        input, select, textarea { padding: 12px 15px; background: rgba(255,255,255,0.07); border: 1.5px solid rgba(255,255,255,0.15); border-radius: 10px; font-size: 1rem; color: white; transition: all 0.3s; }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #FFC107; background: rgba(255,255,255,0.11); box-shadow: 0 0 0 3px rgba(255,193,7,0.15); }
        select option { background: #2d1b4e; color: white; }
        input::placeholder, textarea::placeholder { color: rgba(255,255,255,0.3); }
        textarea { resize: vertical; min-height: 80px; }
        .required { color: #FFC107; margin-left: 2px; }
        .btn-group { display: flex; gap: 15px; justify-content: flex-end; flex-wrap: wrap; margin-top: 10px; }
        .btn { padding: 13px 30px; border: none; border-radius: 25px; font-size: 1rem; font-weight: 700; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-primary { background: linear-gradient(135deg, #FFC107, #FF8C00); color: #1a0a2e; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255,193,7,0.4); }
        .btn-secondary { background: transparent; color: white; border: 2px solid rgba(255,255,255,0.3); }
        .btn-secondary:hover { border-color: #FFC107; color: #FFC107; }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="topbar-left">
            <a href="dashboard.jsp"><img src="image/logo_mini.png" alt="Drive School"></a>
            <div class="user-info"><i class="fa fa-user-shield"></i><span><strong><%= username %></strong> (Admin)</span></div>
        </div>
        <a href="logout.jsp" class="btn-sair"><i class="fa fa-sign-out-alt"></i> Sair</a>
    </div>

    <div class="container">
        <div class="form-card">
            <div class="form-header">
                <div class="icon-wrap"><i class="fa fa-tools"></i></div>
                <h1>Registar Nova Manutenção</h1>
                <p>Preencha os dados abaixo para registar uma manutenção</p>
            </div>

            <% if ("success".equals(request.getParameter("msg"))) { %>
                <div class="alert alert-success"><i class="fa fa-check-circle fa-2x"></i><div><strong>Sucesso!</strong><br>Manutenção registada com sucesso!</div></div>
            <% } %>
            <% if ("error".equals(request.getParameter("msg"))) { %>
                <div class="alert alert-error"><i class="fa fa-exclamation-triangle fa-2x"></i><div><strong>Erro!</strong><br>Erro ao registar manutenção! Verifica os dados.</div></div>
            <% } %>

            <form method="POST" action="adicionar_manutencao.jsp">
                <div class="form-grid">
                    <div class="form-group">
                        <label><i class="fa fa-car"></i> Veículo <span class="required">*</span></label>
                        <select name="idVeiculo" required>
                            <option value="">Selecione o veículo...</option>
                            <%
                                Connection conn = null; Statement stmt = null; ResultSet rs = null;
                                try {
                                    conn = ConexaoBD.getConnection();
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery("SELECT id, marca, modelo, matricula FROM veiculo ORDER BY marca, modelo");
                                    while (rs.next()) {
                            %>
                                <option value="<%= rs.getInt("id") %>"><%= rs.getString("marca") %> <%= rs.getString("modelo") %> (<%= rs.getString("matricula") %>)</option>
                            <%
                                    }
                                } catch (Exception e) { e.printStackTrace(); }
                                finally { try { if(rs!=null)rs.close(); if(stmt!=null)stmt.close(); if(conn!=null)conn.close(); } catch(SQLException e){} }
                            %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label><i class="fa fa-calendar"></i> Data da Manutenção <span class="required">*</span></label>
                        <input type="date" name="dataManutencao" required>
                    </div>
                    <div class="form-group">
                        <label><i class="fa fa-tachometer-alt"></i> Quilometragem <span class="required">*</span></label>
                        <input type="number" name="quilometragem" required placeholder="Ex: 45000">
                    </div>
                    <div class="form-group">
                        <label><i class="fa fa-wrench"></i> Tipo <span class="required">*</span></label>
                        <select name="tipo" required>
                            <option value="">Selecione...</option>
                            <option value="Revisão">Revisão</option>
                            <option value="Pneus">Pneus</option>
                            <option value="Travões">Travões</option>
                            <option value="Óleo">Óleo</option>
                            <option value="IPO">IPO</option>
                            <option value="Outro">Outro</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label><i class="fa fa-euro-sign"></i> Custo (€) <span class="required">*</span></label>
                        <input type="number" step="0.01" name="custo" required placeholder="Ex: 150.00">
                    </div>
                    <div class="form-group">
                        <label><i class="fa fa-building"></i> Oficina</label>
                        <input type="text" name="oficina" placeholder="Ex: Oficina Central">
                    </div>
                    <div class="form-group full-width">
                        <label><i class="fa fa-comment"></i> Descrição</label>
                        <textarea name="descricao" placeholder="Descrição dos trabalhos realizados..."></textarea>
                    </div>
                </div>
                <div class="btn-group">
                    <a href="listar_manutencoes.jsp" class="btn btn-secondary"><i class="fa fa-times"></i> Cancelar</a>
                    <button type="submit" class="btn btn-primary"><i class="fa fa-save"></i> Guardar Manutenção</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>




