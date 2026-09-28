using DimDim.Api.Data;
using DimDim.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DimDim.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ClientesController : ControllerBase
{
    private readonly AppDbContext _db;

    public ClientesController(AppDbContext db) => _db = db;

    // GET api/clientes
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Cliente>>> GetAll()
    {
        var lista = await _db.Clientes.Include(c => c.Transacoes).AsNoTracking().ToListAsync();
        return Ok(lista);
    }

    // GET api/clientes/1
    [HttpGet("{id:int}")]
    public async Task<ActionResult<Cliente>> GetById(int id)
    {
        var cliente = await _db.Clientes.Include(c => c.Transacoes)
            .AsNoTracking().FirstOrDefaultAsync(c => c.Id == id);
        if (cliente is null) return NotFound();
        return Ok(cliente);
    }

    // POST api/clientes
    [HttpPost]
    public async Task<ActionResult<Cliente>> Create(Cliente cliente)
    {
        if (await _db.Clientes.AnyAsync(c => c.Email == cliente.Email))
            return Conflict(new { erro = "E-mail já cadastrado." });

        cliente.Id = 0;
        cliente.DataCadastro = DateTime.UtcNow;
        cliente.Transacoes = new();

        _db.Clientes.Add(cliente);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = cliente.Id }, cliente);
    }

    // PUT api/clientes/1
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, Cliente input)
    {
        var cliente = await _db.Clientes.FindAsync(id);
        if (cliente is null) return NotFound();

        if (await _db.Clientes.AnyAsync(c => c.Email == input.Email && c.Id != id))
            return Conflict(new { erro = "E-mail já cadastrado." });

        cliente.Nome = input.Nome;
        cliente.Email = input.Email;
        await _db.SaveChangesAsync();

        return NoContent();
    }

    // DELETE api/clientes/1  (remove também as transações: ON DELETE CASCADE)
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var cliente = await _db.Clientes.FindAsync(id);
        if (cliente is null) return NotFound();

        _db.Clientes.Remove(cliente);
        await _db.SaveChangesAsync();

        return NoContent();
    }
}
