using DimDim.Api.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Application Insights: lê APPLICATIONINSIGHTS_CONNECTION_STRING (app setting no Azure)
builder.Services.AddApplicationInsightsTelemetry();

// Azure SQL: no App Service a connection string "DefaultConnection" (tipo SQLAzure)
// é injetada automaticamente em ConnectionStrings:DefaultConnection
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Swagger habilitado em todos os ambientes para facilitar a demonstração em sala
app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/", () => Results.Redirect("/swagger"));
app.MapControllers();

app.Run();
