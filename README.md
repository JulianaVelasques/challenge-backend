<h1 align="center"> 🛒 E-commerce Cart API <h1>
<h4 align="center">
  🚀 An API to deal with carts
</h4>

<p align="center">
  
  <img alt="Repository size" src="https://img.shields.io/github/repo-size/JulianaVelasques/challenge-backend">
  
  <a href="https://github.com/JulianaVelasques/challenge-backend/commits/main">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/JulianaVelasques/challenge-backend">
  </a>

  <a href="https://github.com/JulianaVelasques/challenge-backend/issues">
    <img alt="Repository issues" src="https://img.shields.io/github/issues/JulianaVelasques/challenge-backend">
  </a>

  <img alt="License" src="https://img.shields.io/badge/license-MIT-brightgreen">
</p>

<p align="center">
  <a href="#page_with_curl-about">About</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#construction-folder-structuret">Folder Structure</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#wrench-built-with">Built With</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-how-to-contribute">How to Contribute</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#grin-notes">Notes</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#woman_technologist-author">Author</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#memo-license">License</a>
</p>
 
## :page_with_curl: About
Este projeto é uma API para gerenciamento de carrinho de compras em um e-commerce, construída com Ruby on Rails. Ele suporta operações como adicionar e remover produtos, além de marcar e excluir carrinhos abandonados automaticamente usando um async job.

### The Challenge
O desafio consiste em uma API para gerenciamento do um carrinho de compras de e-commerce. Se quiser mais detalhes sobre o desafio acesse: [Challenge Description](https://github.com/JulianaVelasques/challenge-backend/blob/main/challenge_description.md)


## :construction: Folder Structure
```bash
├── app/                 # Código-fonte da aplicação
│   ├── controllers/     # Controllers da API
│   ├── models/          # Modelos do ActiveRecord
│   ├── sidekiq/         # Background jobs
│   ├── services/        # Serviços auxiliares
├── config/              # Configurações da aplicação
├── db/                  # Migrations e schema do banco
├── spec/                # Testes automatizados (RSpec)
│   ├── factories/       # FactoryBot para geração de dados
│   ├── models/          # Testes dos models
│   ├── requests/        # Testes de integração da API
│   ├── routing/          # Testes dos routes
│   ├── sidekiq/         # Testes dos jobs do Sidekiq
├── Dockerfile           # Configuração do container
├── docker-compose.yml   # Orquestração dos containers
├── bin/docker-entrypoint # Script de inicialização do container
├── challenge_description # Texto sobre os requisitos do Desafio
└── README.md            # Documentação do projeto
```
## :wrench: Built With
- [Ruby on Rails](https://rubyonrails.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [Sidekiq](https://sidekiq.org/)
- [Rspec](https://rspec.info/)
- [Docker](https://www.docker.com/)

## 🚀 Getting Started
### 🐳 Running with Docker
1) Clone the project:
```bash
git clone https://github.com/seu-usuario/seu-repo.git
cd seu-repo
```

2) Start the containers:
```bash
docker-compose up --build
```

## 🤔 How to Contribute

- Clone the project: `git clone git@github.com:JulianaVelasques/challenge-backend.git`;
- Create your branch with your feature: `git checkout -b my-feature`;
- Commit your feature: `git commit -m 'feat: My new feature'`;
- Push to your branch: `git push -u origin my-feature`.

After merging your pull request, you can delete your branch.

## :grin: Notes
- O sistema de carrinhos abandonados é gerenciado por um Sidekiq Job, que marca e remove carrinhos automaticamente.
- O banco de dados e o Redis são inicializados automaticamente pelo Docker Compose.
- A lógica dos endpoints POST /cart e POST /cart/add_item foi ajustada para separar claramente suas responsabilidades:
  - POST /cart serve exclusivamente para inicializar um carrinho e adicionar o primeiro produto. Se o usuário tentar adicionar o mesmo produto novamente, um erro será retornado, pois esse endpoint não deve modificar itens já existentes—apenas criar o carrinho com o primeiro item.
  - POST /cart/add_item é o endpoint adequado para adicionar novos produtos ou incrementar a quantidade de itens já existentes no carrinho.
Essa abordagem evita inconsistências e garante um fluxo mais previsível para o frontend.
- Também foi implementado o POST /cart/decrease_quantity, que faz o oposto do add_item, permitindo reduzir a quantidade de um produto no carrinho.


## :woman_technologist: Author
- LinkedIn - [Juliana Velasques Balta dos Santos](https://www.linkedin.com/in/julianavelasquesbalta/)
  
## :memo: License

This project is under the MIT license. See the [LICENSE](LICENSE.md) file for more details.

---

Made with ♥ by <tr>
    <td align="center"><a href="https://github.com/JulianaVelasques"><b>Juliana Velasques</b></a><br /></td>
<tr>
