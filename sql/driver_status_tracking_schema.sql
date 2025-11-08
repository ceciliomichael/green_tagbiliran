-- Driver Status Tracking Schema
-- This migration adds status-based tracking to replace GPS map tracking

-- Step 1: Create driver_status_updates table
CREATE TABLE IF NOT EXISTS public.driver_status_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  barangay VARCHAR(100) NOT NULL,
  status VARCHAR(50) NOT NULL,
  status_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Add constraint for valid status values (19 granular waypoints)
ALTER TABLE public.driver_status_updates 
DROP CONSTRAINT IF EXISTS driver_status_valid;

ALTER TABLE public.driver_status_updates 
ADD CONSTRAINT driver_status_valid 
CHECK (status IN (
  'not_started',
  -- Northern Cogon
  'cp_garcia_avenue', 'calceta_street', 'hangos_street', 'torralba_street',
  -- Central Cogon
  'inting_street', 'parras_street', 'enerio_street', 'rocha_street',
  -- South Cogon
  'tamblot_street', 'borja_street', 'palma_street', 'putong_street',
  -- West Cogon
  'gallares_street', 'cogon_market', 'pamaong_street',
  -- Final Sweep
  'metrobank_cogon', 'bus_terminal',
  -- Completed
  'completed'
));

-- Step 3: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_driver_status_driver_id 
ON public.driver_status_updates(driver_id);

CREATE INDEX IF NOT EXISTS idx_driver_status_barangay 
ON public.driver_status_updates(barangay);

CREATE INDEX IF NOT EXISTS idx_driver_status_created_at 
ON public.driver_status_updates(created_at DESC);

-- Composite index for fetching latest status per barangay
CREATE INDEX IF NOT EXISTS idx_driver_status_barangay_created 
ON public.driver_status_updates(barangay, created_at DESC);

-- Step 4: Add comments for documentation
COMMENT ON TABLE public.driver_status_updates IS 'Stores granular driver status updates for street-level tracking in Cogon';
COMMENT ON COLUMN public.driver_status_updates.status IS 'Status values: 19 waypoints from not_started through all Cogon streets to completed';
COMMENT ON COLUMN public.driver_status_updates.status_message IS 'Human-readable status message showing current street/location';

-- Step 5: Enable RLS (Row Level Security)
ALTER TABLE public.driver_status_updates ENABLE ROW LEVEL SECURITY;

-- Step 6: Create RLS policies
-- Drivers can insert their own status updates
CREATE POLICY "Drivers can insert own status" ON public.driver_status_updates
  FOR INSERT WITH CHECK (
    driver_id::text = auth.uid()::text AND
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'truck_driver'
  );

-- All authenticated users can view status updates
CREATE POLICY "Users can view all status updates" ON public.driver_status_updates
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Drivers can update their own status updates
CREATE POLICY "Drivers can update own status" ON public.driver_status_updates
  FOR UPDATE USING (
    driver_id::text = auth.uid()::text AND
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'truck_driver'
  );

-- Admins can view and manage all status updates
CREATE POLICY "Admins can manage all status" ON public.driver_status_updates
  FOR ALL USING (
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
  );

