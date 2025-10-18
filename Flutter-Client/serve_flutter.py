"""
Flask/aiohttp route configuration for serving Flutter Web client
alongside the existing Angular frontend.

Add this to your existing app/main.py
"""

from aiohttp import web
import aiohttp_cors
from pathlib import Path

def setup_flutter_routes(app):
    """
    Configure routes to serve Flutter Web client.

    This function should be called in your main.py after creating the app.

    Example:
        app = web.Application()
        setup_routes(app)  # Your existing routes
        setup_flutter_routes(app)  # Add Flutter Web support
    """

    # Path to Flutter Web build directory
    flutter_build_dir = Path(__file__).parent.parent / 'flutter-web' / 'build' / 'web'

    if not flutter_build_dir.exists():
        print(f"⚠️  Flutter Web build not found at {flutter_build_dir}")
        print("   Run: cd flutter-web && flutter build web")
        return

    # Serve Flutter Web static files
    app.router.add_static(
        '/flutter-web',
        path=str(flutter_build_dir),
        name='flutter_web',
        show_index=True
    )

    # Route for Flutter Web index (catches all routes for SPA routing)
    async def serve_flutter_index(request):
        """Serve Flutter Web index.html for all /flutter-web/* routes"""
        return web.FileResponse(flutter_build_dir / 'index.html')

    # Catch-all route for Flutter Web (must be last)
    app.router.add_get('/flutter-web/{tail:.*}', serve_flutter_index)

    print(f"✅ Flutter Web client configured at /flutter-web")
    print(f"   Build directory: {flutter_build_dir}")


def setup_dual_frontend(app, default='angular'):
    """
    Configure both Angular and Flutter Web frontends.

    Args:
        app: aiohttp Application instance
        default: 'angular' or 'flutter' - which frontend to serve at /

    Example:
        app = web.Application()
        setup_routes(app)  # API routes
        setup_dual_frontend(app, default='flutter')
    """

    # Paths
    flutter_dir = Path(__file__).parent.parent / 'flutter-web' / 'build' / 'web'
    angular_dir = Path(__file__).parent.parent / 'ui' / 'dist' / 'metube' / 'browser'

    # Setup CORS for both frontends
    cors = aiohttp_cors.setup(app, defaults={
        "*": aiohttp_cors.ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*",
            allow_methods=["GET", "POST", "OPTIONS", "PUT", "DELETE"]
        )
    })

    # Serve Angular
    if angular_dir.exists():
        app.router.add_static('/angular', path=str(angular_dir), name='angular')

        async def serve_angular(request):
            return web.FileResponse(angular_dir / 'index.html')

        app.router.add_get('/angular/{tail:.*}', serve_angular)
        print(f"✅ Angular client at /angular")
    else:
        print(f"⚠️  Angular build not found at {angular_dir}")

    # Serve Flutter Web
    if flutter_dir.exists():
        app.router.add_static('/flutter-web', path=str(flutter_dir), name='flutter_web')

        async def serve_flutter(request):
            return web.FileResponse(flutter_dir / 'index.html')

        app.router.add_get('/flutter-web/{tail:.*}', serve_flutter)
        print(f"✅ Flutter Web client at /flutter-web")
    else:
        print(f"⚠️  Flutter Web build not found at {flutter_dir}")

    # Default route (/)
    async def serve_default(request):
        if default == 'flutter' and flutter_dir.exists():
            return web.FileResponse(flutter_dir / 'index.html')
        elif default == 'angular' and angular_dir.exists():
            return web.FileResponse(angular_dir / 'index.html')
        else:
            # Fallback: show selection page
            return web.Response(
                text="""
                <!DOCTYPE html>
                <html>
                <head>
                    <title>GrabTube</title>
                    <style>
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            height: 100vh;
                            margin: 0;
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        }
                        .container {
                            text-align: center;
                            background: white;
                            padding: 3rem;
                            border-radius: 1rem;
                            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                        }
                        h1 {
                            color: #333;
                            margin-bottom: 2rem;
                        }
                        .buttons {
                            display: flex;
                            gap: 1rem;
                            justify-content: center;
                        }
                        a {
                            display: inline-block;
                            padding: 1rem 2rem;
                            text-decoration: none;
                            border-radius: 0.5rem;
                            font-weight: 600;
                            transition: transform 0.2s;
                        }
                        a:hover {
                            transform: translateY(-2px);
                        }
                        .flutter {
                            background: #02569B;
                            color: white;
                        }
                        .angular {
                            background: #DD0031;
                            color: white;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1>🎬 GrabTube</h1>
                        <p>Choose your frontend:</p>
                        <div class="buttons">
                            <a href="/flutter-web" class="flutter">Flutter Web ⚡</a>
                            <a href="/angular" class="angular">Angular 🅰️</a>
                        </div>
                    </div>
                </body>
                </html>
                """,
                content_type='text/html'
            )

    app.router.add_get('/', serve_default)

    # Apply CORS to all routes
    for route in list(app.router.routes()):
        cors.add(route)

    print(f"✅ Default route (/) → {default}")
    print(f"✅ CORS configured for both frontends")


# Example usage in main.py:
"""
from aiohttp import web
from app.serve_flutter import setup_dual_frontend

def create_app():
    app = web.Application()

    # Your existing API routes
    setup_routes(app)

    # Add Flutter Web + Angular support
    setup_dual_frontend(app, default='flutter')

    return app

if __name__ == '__main__':
    app = create_app()
    web.run_app(app, host='0.0.0.0', port=8081)
"""
