<%-- 
    Document   : marcar_aula
    Created on : 15/01/2026, 10:13:06
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Aluno".equals(tipo)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");

    Integer idAluno = null;
    Integer idInstrutor = null;
    Integer idVeiculo = null;
    String nomeInstrutor = "";
    String veiculoInfo = "";
    
    Connection connUser = null;
    PreparedStatement pstmtUser = null;
    ResultSet rsUser = null;
    
    try {
        connUser = ConexaoBD.getConnection();
        String sqlUser = "SELECT email FROM t_utilizador WHERE username = ?";
        pstmtUser = connUser.prepareStatement(sqlUser);
        pstmtUser.setString(1, username);
        rsUser = pstmtUser.executeQuery();
        
        String emailUtilizador = "";
        if (rsUser.next()) {
            emailUtilizador = rsUser.getString("email");
        }
        rsUser.close();
        pstmtUser.close();
        
        if (!emailUtilizador.isEmpty()) {
            String sqlAluno = "SELECT a.id, a.idInstrutor, i.nome as nomeInstrutor, i.idVeiculo, " +
                             "v.marca, v.modelo, v.matricula " +
                             "FROM aluno a " +
                             "LEFT JOIN instrutor i ON a.idInstrutor = i.id " +
                             "LEFT JOIN veiculo v ON i.idVeiculo = v.id " +
                             "WHERE a.email = ?";
            pstmtUser = connUser.prepareStatement(sqlAluno);
            pstmtUser.setString(1, emailUtilizador);
            rsUser = pstmtUser.executeQuery();
            
            if (rsUser.next()) {
                idAluno = rsUser.getInt("id");
                idInstrutor = rsUser.getInt("idInstrutor");
                idVeiculo = rsUser.getInt("idVeiculo");
                nomeInstrutor = rsUser.getString("nomeInstrutor");
                
                String marca = rsUser.getString("marca");
                String modelo = rsUser.getString("modelo");
                String matricula = rsUser.getString("matricula");
                
                if (marca != null && modelo != null) {
                    veiculoInfo = marca + " " + modelo + " (" + matricula + ")";
                }
                if (nomeInstrutor == null) nomeInstrutor = "";
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rsUser != null) rsUser.close();
            if (pstmtUser != null) pstmtUser.close();
            if (connUser != null) connUser.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    String mensagemSucesso = null;
    String mensagemErro = null;
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String dataAula = request.getParameter("dataAula");
        String horaInicio = request.getParameter("horaInicio");
        String duracao = request.getParameter("duracao");
        
        if (dataAula != null && horaInicio != null && duracao != null && idVeiculo != null && idVeiculo != 0) {
            Connection connMarcar = null;
            PreparedStatement pstmtMarcar = null;
            ResultSet rsLimite = null;
            
            try {
                connMarcar = ConexaoBD.getConnection();
                
                // VALIDAÇÃO 1: VERIFICAR LIMITE DIÁRIO (2H = 120MIN)
                String sqlLimite = "SELECT SUM(TIMESTAMPDIFF(MINUTE, dataHoraInicio, dataHoraFim)) as totalMinutos " +
                                  "FROM aula_conducao " +
                                  "WHERE idAluno = ? " +
                                  "AND DATE(dataHoraInicio) = ? " +
                                  "AND estado = 'Agendada'";
                
                pstmtMarcar = connMarcar.prepareStatement(sqlLimite);
                pstmtMarcar.setInt(1, idAluno);
                pstmtMarcar.setString(2, dataAula);
                rsLimite = pstmtMarcar.executeQuery();
                
                int minutosJaAgendados = 0;
                if (rsLimite.next()) {
                    minutosJaAgendados = rsLimite.getInt("totalMinutos");
                }
                rsLimite.close();
                pstmtMarcar.close();
                
                int duracaoNova = Integer.parseInt(duracao);
                int totalMinutos = minutosJaAgendados + duracaoNova;
                
                // Verificar se excede 120 minutos (2 horas)
                if (totalMinutos > 120) {
                    int minutosDisponiveis = 120 - minutosJaAgendados;
                    if (minutosDisponiveis <= 0) {
                        mensagemErro = "❌ Limite diário atingido! Já tens 2 horas de aulas marcadas neste dia.";
                    } else {
                        mensagemErro = "❌ Esta aula excede o limite! Já tens " + minutosJaAgendados + 
                                      " min agendados. Só podes marcar mais " + minutosDisponiveis + " min neste dia.";
                    }
                } else {
                    // DENTRO DO LIMITE - PODE MARCAR
                    String dataHoraInicio = dataAula + " " + horaInicio + ":00";
                    
                    String sqlMarcar = "INSERT INTO aula_conducao (idAluno, idInstrutor, idVeiculo, dataHoraInicio, dataHoraFim, estado) " +
                                       "VALUES (?, ?, ?, ?, DATE_ADD(?, INTERVAL ? MINUTE), 'Agendada')";
                    
                    pstmtMarcar = connMarcar.prepareStatement(sqlMarcar);
                    pstmtMarcar.setInt(1, idAluno);
                    pstmtMarcar.setInt(2, idInstrutor);
                    pstmtMarcar.setInt(3, idVeiculo);
                    pstmtMarcar.setString(4, dataHoraInicio);
                    pstmtMarcar.setString(5, dataHoraInicio);
                    pstmtMarcar.setInt(6, duracaoNova);
                    
                    int resultado = pstmtMarcar.executeUpdate();
                    
                    if (resultado > 0) {
                        mensagemSucesso = "✅ Aula marcada! Tens agora " + totalMinutos + " min agendados neste dia (máx: 120min).";
                    } else {
                        mensagemErro = "Erro ao marcar aula.";
                    }
                }
                
            } catch (Exception e) {
                mensagemErro = "Erro: " + e.getMessage();
                e.printStackTrace();
            } finally {
                try {
                    if (rsLimite != null) rsLimite.close();
                    if (pstmtMarcar != null) pstmtMarcar.close();
                    if (connMarcar != null) connMarcar.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Marcar Aula - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Work Sans', sans-serif;
            background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%);
            background-attachment: fixed;
            color: white;
            min-height: 100vh;
        }
        
        .topbar {
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(10px);
            padding: 15px 0;
            border-bottom: 1px solid rgba(255, 193, 7, 0.2);
        }
        
        .topbar .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .topbar .user-info {
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .topbar .user-info i {
            color: #FFC107;
        }
        
        .btn-sair {
            background: rgba(128, 0, 32, 0.8);
            color: white;
            padding: 10px 25px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .btn-sair:hover {
            background: #800020;
            transform: translateY(-2px);
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        
        .logo-link {
            display: block;
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo-link img {
            height: 60px;
            width: auto;
            filter: drop-shadow(0 0 10px rgba(255, 193, 7, 0.3));
        }
        
        .content-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 193, 7, 0.2);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .page-header h1 {
            color: white;
            font-size: 2rem;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .page-header h1 i {
            color: #FFC107;
        }
        
        .btn {
            padding: 12px 25px;
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
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .btn:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: #FFC107;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .info-box {
            background: rgba(255, 193, 7, 0.1);
            border: 1px solid rgba(255, 193, 7, 0.3);
            border-radius: 15px;
            padding: 20px;
        }
        
        .info-box h3 {
            color: #FFC107;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1rem;
        }
        
        .info-box p {
            color: rgba(255, 255, 255, 0.9);
            font-size: 1.1rem;
            font-weight: 600;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 15px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 10px;
            color: white;
            font-size: 1rem;
            font-family: 'Work Sans', sans-serif;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #FFC107;
            background: rgba(255, 255, 255, 0.15);
        }
        
        .form-group select option {
            background: #1a3a4d;
            color: white;
        }
        
        .form-group select option:disabled {
            background: #2a2a2a;
            color: #666;
        }
        
        .btn-submit {
            background: rgba(76, 175, 80, 0.3);
            color: #4CAF50;
            border: 2px solid #4CAF50;
            width: 100%;
            padding: 15px;
            font-size: 1.1rem;
        }
        
        .btn-submit:hover {
            background: #4CAF50;
            color: white;
        }
        
        .mensagem {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 600;
        }
        
        .mensagem-sucesso {
            background: rgba(76, 175, 80, 0.2);
            border: 1px solid #4CAF50;
            color: #4CAF50;
        }
        
        .mensagem-erro {
            background: rgba(244, 67, 54, 0.2);
            border: 1px solid #f44336;
            color: #f44336;
        }
        
        .error-state {
            text-align: center;
            padding: 40px 20px;
        }
        
        .error-state i {
            font-size: 3rem;
            color: rgba(255, 193, 7, 0.3);
            margin-bottom: 20px;
        }
        
        .loading {
            display: none;
            text-align: center;
            padding: 10px;
            color: #FFC107;
        }
        
        @media (max-width: 768px) {
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="container">
            <div class="user-info">
                <i class="fa fa-user-graduate"></i>
                <span><strong><%= username %></strong> (Aluno)</span>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <div class="container">
        <a href="dashboard_aluno.jsp" class="logo-link">
            <img src="image/logo.png" alt="Drive School">
        </a>

        <div class="content-card">
            <div class="page-header">
                <h1>
                    <i class="fa fa-calendar-plus"></i>
                    Marcar Aula
                </h1>
                <a href="minhas_aulas.jsp" class="btn">
                    <i class="fa fa-arrow-left"></i>
                    Voltar
                </a>
            </div>

            <% if (mensagemSucesso != null) { %>
                <div class="mensagem mensagem-sucesso">
                    <%= mensagemSucesso %>
                </div>
            <% } %>

            <% if (mensagemErro != null) { %>
                <div class="mensagem mensagem-erro">
                    <%= mensagemErro %>
                </div>
            <% } %>

            <%
            if (idAluno == null || idInstrutor == null || idInstrutor == 0) {
            %>
                <div class="error-state">
                    <i class="fa fa-exclamation-triangle"></i>
                    <h3>Instrutor não atribuído</h3>
                    <p>Ainda não tens um instrutor atribuído. Contacta a administração.</p>
                </div>
            <%
            } else if (idVeiculo == null || idVeiculo == 0) {
            %>
                <div class="error-state">
                    <i class="fa fa-exclamation-triangle"></i>
                    <h3>Instrutor sem veículo</h3>
                    <p>O teu instrutor ainda não tem um veículo atribuído. Contacta a administração.</p>
                </div>
            <%
            } else {
            %>
                <div class="info-grid">
                    <div class="info-box">
                        <h3>
                            <i class="fa fa-user"></i>
                            Teu Instrutor
                        </h3>
                        <p><%= nomeInstrutor %></p>
                    </div>

                    <div class="info-box">
                        <h3>
                            <i class="fa fa-car"></i>
                            Veículo
                        </h3>
                        <p><%= veiculoInfo %></p>
                    </div>
                </div>

                <form method="POST" action="marcar_aula.jsp" id="formMarcar">
                    <input type="hidden" id="idInstrutor" value="<%= idInstrutor %>">
                    
                    <div class="form-group">
                        <label>
                            <i class="fa fa-calendar"></i>
                            Data da Aula
                        </label>
                        <input type="date" name="dataAula" id="dataAula" required 
                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                    </div>

                    <div class="loading" id="loading">
                        <i class="fa fa-spinner fa-spin"></i> A carregar horários...
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fa fa-clock"></i>
                            Hora de Início
                        </label>
                        <select name="horaInicio" id="horaInicio" required disabled>
                            <option value="">Seleciona primeiro uma data...</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fa fa-hourglass-half"></i>
                            Duração
                        </label>
                        <select name="duracao" required>
                            <option value="">Seleciona a duração...</option>
                            <option value="30">30 minutos</option>
                            <option value="60">60 minutos (1 hora)</option>
                            <option value="90">90 minutos (1h30)</option>
                            <option value="120">120 minutos (2 horas)</option>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-submit">
                        <i class="fa fa-check"></i>
                        Confirmar Marcação
                    </button>
                </form>
            <% } %>
        </div>
    </div>

    <script>
        const horariosDisponiveis = [
            '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
            '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'
        ];

        document.getElementById('dataAula').addEventListener('change', function() {
            const data = this.value;
            const idInstrutor = document.getElementById('idInstrutor').value;
            const selectHora = document.getElementById('horaInicio');
            const loading = document.getElementById('loading');
            
            if (!data) return;
            
            loading.style.display = 'block';
            selectHora.disabled = true;
            selectHora.innerHTML = '<option value="">A carregar...</option>';
            
            fetch('verificar_disponibilidade.jsp?data=' + data + '&idInstrutor=' + idInstrutor)
                .then(response => response.json())
                .then(data => {
                    loading.style.display = 'none';
                    
                    if (data.sucesso) {
                        const ocupados = data.ocupados || [];
                        
                        selectHora.innerHTML = '<option value="">Seleciona uma hora...</option>';
                        
                        horariosDisponiveis.forEach(hora => {
                            const ocupado = ocupados.some(aula => {
                                return hora >= aula.inicio && hora < aula.fim;
                            });
                            
                            if (!ocupado) {
                                const option = document.createElement('option');
                                option.value = hora;
                                option.textContent = hora;
                                selectHora.appendChild(option);
                            }
                        });
                        
                        selectHora.disabled = false;
                        
                        if (selectHora.options.length === 1) {
                            selectHora.innerHTML = '<option value="">Sem horários disponíveis neste dia</option>';
                            selectHora.disabled = true;
                        }
                    } else {
                        selectHora.innerHTML = '<option value="">Erro ao carregar horários</option>';
                    }
                })
                .catch(error => {
                    loading.style.display = 'none';
                    selectHora.innerHTML = '<option value="">Erro ao carregar horários</option>';
                    console.error('Erro:', error);
                });
        });
    </script>
</body>
</html>



