<?php

namespace App\Console\Commands;

use App\Models\Media;
use Illuminate\Console\Command;

class CleanupOrphanedMedia extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'media:cleanup-orphaned {--dry-run : Run without actually deleting files}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clean up orphaned media files that are not referenced by any entity';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting orphaned media cleanup...');
        
        $dryRun = $this->option('dry-run');
        
        if ($dryRun) {
            $this->warn('Running in DRY RUN mode - no files will be deleted');
        }
        
        $allMedia = Media::all();
        $orphanedCount = 0;
        $orphanedMedia = [];
        
        $this->info("Checking {$allMedia->count()} media files...");
        
        $progressBar = $this->output->createProgressBar($allMedia->count());
        $progressBar->start();
        
        foreach ($allMedia as $media) {
            if (!$media->isInUse()) {
                $orphanedCount++;
                $orphanedMedia[] = [
                    'id' => $media->id,
                    'name' => $media->name,
                    'path' => $media->path,
                    'size' => $media->size,
                ];
                
                if (!$dryRun) {
                    $media->safeDelete(true);
                }
            }
            $progressBar->advance();
        }
        
        $progressBar->finish();
        $this->newLine(2);
        
        if ($orphanedCount > 0) {
            $this->info("Found {$orphanedCount} orphaned media files:");
            $this->table(
                ['ID', 'Name', 'Path', 'Size (bytes)'],
                array_map(function($item) {
                    return [
                        $item['id'],
                        $item['name'],
                        $item['path'],
                        number_format($item['size']),
                    ];
                }, $orphanedMedia)
            );
            
            if ($dryRun) {
                $this->warn("DRY RUN: {$orphanedCount} files would be deleted");
                $this->info('Run without --dry-run to actually delete these files');
            } else {
                $this->info("Successfully deleted {$orphanedCount} orphaned media files");
            }
        } else {
            $this->info('No orphaned media files found. All media is properly referenced!');
        }
        
        return Command::SUCCESS;
    }
}
