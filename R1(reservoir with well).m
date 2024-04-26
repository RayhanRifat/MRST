
% Define grid dimensions
[nx, ny, nz] = deal(30, 30, 10);

% Create Cartesian grid
G = cartGrid([nx, ny, nz]);

% Compute geometry of the grid
G = computeGeometry(G);

% Define rock properties
rock = makeRock(G, 200*milli*darcy, 0.25);

% Compute transmissibility
hT = computeTrans(G, rock);

% Add incompressible fluid module
mrstModule add incomp

% Initialize fluid properties
fluid = initSingleFluid('mu', 1*centi*poise, 'rho', 1000);

% Define injector well
W = verticalWell([], G, rock, 1, 1, 1:nz, ...
    'Type', 'rate', 'Val', 1000*meter^3/day, ...
    'Comp_i', 1, 'Radius', 0.1, 'Name', 'Injector');

% Define producer well
W = verticalWell(W, G, rock, nx, ny, 1:nz, ...
    'Type', 'bhp', 'Val', 800*psia, ...
    'Comp_i', 1, 'Radius', 0.1, 'Name', 'Producer');

% Enable gravity
gravity on

% Initialize reservoir state
state = initState(G, W, 3000*psia);

% Perform incompressible two-point flux approximation (TPFA) simulation
state = incompTPFA(state, G, hT, fluid, 'Wells', W);

% Plot cell data (pressure)
plotCellData(G, convertTo(state.pressure, psia));
plotWell(G,W(1),'Height',2,'Color','b')
plotWell(G,W(2),'Height',2,'Color','k')
view(3)
axis tigh off
colormap ('Jet')
colorbar