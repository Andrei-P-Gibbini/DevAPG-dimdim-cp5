using DimDim.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace DimDim.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Cliente> Clientes => Set<Cliente>();
    public DbSet<Transacao> Transacoes => Set<Transacao>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Cliente>(e =>
        {
            e.ToTable("Clientes");
            e.HasIndex(x => x.Email).IsUnique();
        });

        modelBuilder.Entity<Transacao>(e =>
        {
            e.ToTable("Transacoes", t =>
            {
                t.HasCheckConstraint("CK_Transacoes_Tipo", "[Tipo] IN ('DEPOSITO', 'SAQUE', 'PIX')");
                t.HasCheckConstraint("CK_Transacoes_Valor", "[Valor] > 0");
            });
            e.Property(x => x.Valor).HasPrecision(18, 2);
            e.HasOne(x => x.Cliente)
             .WithMany(c => c.Transacoes)
             .HasForeignKey(x => x.ClienteId)
             .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
