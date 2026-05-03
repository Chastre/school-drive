<%-- 
    Document   : inscricao_sucesso
    Created on : 07/01/2026, 09:50:11
    Author     : pmnch
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Inscrição Concluída - Escola de Condução</title>
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
            min-height: 100vh;
            background: linear-gradient(135deg, #2C5F7C 0%, #800020 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .success-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 60px 40px;
            max-width: 600px;
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
        
        .success-icon {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, #28a745, #20c997);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            animation: scaleIn 0.5s ease 0.3s both;
        }
        
        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }
        
        .success-icon i {
            font-size: 4rem;
            color: white;
        }
        
        h1 {
            color: #28a745;
            font-size: 2.5rem;
            margin-bottom: 20px;
        }
        
        .message {
            color: #666;
            font-size: 1.1rem;
            line-height: 1.8;
            margin-bottom: 30px;
        }
        
        .info-box {
            background: rgba(255, 193, 7, 0.1);
            border: 2px solid #FFC107;
            padding: 25px;
            border-radius: 15px;
            margin: 30px 0;
            text-align: left;
        }
        
        .info-box h3 {
            color: #2C5F7C;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-box ul {
            list-style: none;
            padding: 0;
        }
        
        .info-box li {
            padding: 10px 0;
            border-bottom: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .info-box li:last-child {
            border-bottom: none;
        }
        
        .info-box li i {
            color: #FFC107;
            margin-right: 10px;
            width: 20px;
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
        
        @media (max-width: 768px) {
            .success-card {
                padding: 40px 20px;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .success-icon {
                width: 100px;
                height: 100px;
            }
            
            .success-icon i {
                font-size: 3rem;
            }
        }
    </style>
</head>
<body>
    <div class="success-card">
        <div class="success-icon">
            <i class="fa fa-check"></i>
        </div>
        
        <h1>Inscrição Concluída!</h1>
        
        <p class="message">
            <strong>Parabéns!</strong> A sua inscrição foi realizada com sucesso.<br>
            O seu email foi verificado e a conta está quase pronta!
        </p>
        
        <div class="info-box">
            <h3>
                <i class="fa fa-info-circle"></i>
                Próximos Passos
            </h3>
            <ul>
                <li>
                    <i class="fa fa-clock"></i>
                    <strong>Aguarde o pagamento:</strong> A escola irá contactá-lo para efetuar o primeiro pagamento
                </li>
                <li>
                    <i class="fa fa-check-circle"></i>
                    <strong>Ativação da conta:</strong> Assim que o pagamento for confirmado, sua conta será ativada automaticamente
                </li>
                <li>
                    <i class="fa fa-sign-in-alt"></i>
                    <strong>Acesso ao sistema:</strong> Após a ativação, poderá fazer login e aceder ao seu painel de aluno
                </li>
                <li>
                    <i class="fa fa-envelope"></i>
                    <strong>Email de confirmação:</strong> Receberá um email quando a conta estiver ativa
                </li>
            </ul>
        </div>
        
        <a href="index.jsp" class="btn btn-primary">
            <i class="fa fa-home"></i>
            Voltar à Página Inicial
        </a>
    </div>
</body>
</html>

