using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.AspNetCore.Components.WebAssembly.Authentication;
using Radzen;

namespace Spa
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            var builder = WebAssemblyHostBuilder.CreateDefault(args);

            builder.RootComponents.Add<App>("#app");

            builder.RootComponents.Add<HeadOutlet>("head::after");

            // builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

            builder.Services.AddHttpClient("api", client => client.BaseAddress = new Uri(builder.HostEnvironment.BaseAddress)).AddHttpMessageHandler<BaseAddressAuthorizationMessageHandler>();

            builder.Services.AddScoped(provider => provider.GetRequiredService<IHttpClientFactory>().CreateClient("api"));

            builder.Services.AddScoped<DialogService>();

            builder.Services.AddScoped<NotificationService>();

            builder.Services.AddScoped<TooltipService>();

            builder.Services.AddScoped<ContextMenuService>();

            builder.Services.AddOidcAuthentication(options =>
            {
                builder.Configuration.Bind("Auth0", options.ProviderOptions);

                options.ProviderOptions.ResponseType = "code";

                options.ProviderOptions.AdditionalProviderParameters.Add("audience", builder.Configuration["Auth0:Audience"]);
            });

            await builder.Build().RunAsync();
        }
    }
}